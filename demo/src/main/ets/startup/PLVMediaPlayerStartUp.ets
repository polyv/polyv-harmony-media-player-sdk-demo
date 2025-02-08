import {
  IPLVKVStore,
  Logger,
  PLVKVStore,
  PLVMediaPlayerAppContext,
  PLVMediaPlayerFactory,
  PLVMediaPlayerHttpDns,
  PLVMediaPlayerLogger,
  runCatching
} from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerCoreIjkProvider } from '@polyvharmony/media-player-core-ijk';
import { Context } from '@ohos.abilityAccessCtrl';
import distributedKVStore from '@ohos.data.distributedKVStore';
import hilog from '@ohos.hilog';
import { PLVMediaDownloaderManager, PLVMediaDownloadSetting } from '@polyvharmony/media-player-sdk-addon-cache-down';
import { PLVLocalDnsService } from '@polyvharmony/httpdns-impl-local';
import { PLVHttpDnsService } from '@polyvharmony/httpdns-impl-ali';
import { PLVHttpDnsManager } from '@polyvharmony/httpdns-api';

export class PLVMediaPlayerStartUp {
  private static isInit = false

  static start(context: Context) {
    if (PLVMediaPlayerStartUp.isInit) {
      return
    }
    PLVMediaPlayerStartUp.isInit = true

    PLVMediaPlayerAppContext.getInstance().setupAppContext(context)
    PLVMediaPlayerLogger.loggerImpl = new HiLogImpl()
    PLVKVStore.setupImplement(new PLVKVStoreOhosImpl(context))
    PLVMediaPlayerFactory.getInstance().register(PLVMediaPlayerCoreIjkProvider.getInstance())
    PLVMediaDownloaderManager.getInstance().init(PLVMediaDownloadSetting.defaultSetting(context))

    PLVHttpDnsManager.getInstance().logger = (tag: string, message: string) => {
      hilog.info(0x0000, tag, message.substring(0, 1000))
    }
    PLVMediaPlayerHttpDns.getInstance().register(PLVLocalDnsService.getInstance())
    PLVMediaPlayerHttpDns.getInstance().register(PLVHttpDnsService.getInstance())
    PLVMediaPlayerHttpDns.getInstance().enable = true
  }
}

class HiLogImpl implements Logger {
  debug(tag: string, message: string) {
    hilog.debug(0x0000, tag, message.substring(0, 1000))
  }

  info(tag: string, message: string) {
    hilog.info(0x0000, tag, message.substring(0, 1000))
  }

  warn(tag: string, message: string) {
    hilog.warn(0x0000, tag, message.substring(0, 1000))
  }

  error(tag: string, message: string) {
    hilog.error(0x0000, tag, message.substring(0, 1000))
  }
}

class PLVKVStoreOhosImpl implements IPLVKVStore {
  private static readonly kvStoreId = "PLVKVStoreOhosImpl"

  constructor(context: Context) {
    this.kvStoreManager = distributedKVStore.createKVManager({
      context: context,
      bundleName: context.applicationInfo.name
    })
    this.ensureKvStore()
  }

  private kvStoreManager: distributedKVStore.KVManager | undefined = undefined;
  private kvStore: distributedKVStore.DeviceKVStore | undefined = undefined;

  async getValue(key: string): Promise<string | undefined> {
    if (!this.kvStore) {
      await this.ensureKvStore()
    }

    const result = await runCatching(this.kvStore?.get(key))
    if (result.success) {
      return result.data as string
    } else {
      return undefined
    }
  }

  async setValue(key: string, value: string): Promise<void> {
    await this.ensureKvStore()
    this.kvStore?.put(key, value)
  }

  async delete(key: string): Promise<void> {
    await this.ensureKvStore()
    this.kvStore?.delete(key)
  }

  private async ensureKvStore() {
    this.kvStore = await this.kvStoreManager?.getKVStore(PLVKVStoreOhosImpl.kvStoreId, {
      securityLevel: distributedKVStore.SecurityLevel.S1
    }) as distributedKVStore.DeviceKVStore
  }
}