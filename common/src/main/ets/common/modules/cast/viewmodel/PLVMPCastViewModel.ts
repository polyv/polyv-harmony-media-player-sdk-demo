import {
  PLVMediaCastController,
  PLVMediaCastData,
  PLVMediaCastDevice,
  PLVMediaCastManager,
  PLVMediaCastPlayState
} from '@polyvharmony/media-cast';
import {
  derivedStateOf,
  Duration,
  LifecycleAwareDependComponent,
  MutableEvent,
  MutableObserver,
  mutableStateOf,
  PLVMediaBitRate,
  runCatching,
  seconds,
  watchStates
} from '@polyvharmony/media-player-sdk';
import { PLVMPMediaMediator } from '../../media/mediator/PLVMPMediaMediator';

export class PLVMPCastViewModel implements LifecycleAwareDependComponent {
  private readonly mediaMediator: PLVMPMediaMediator

  readonly isMediaCastEnable = mutableStateOf(false)
  readonly castController = mutableStateOf<PLVMediaCastController | undefined>(undefined)
  readonly castBitRate = mutableStateOf<PLVMediaBitRate | undefined>(undefined)
  readonly castSupportBitRates = mutableStateOf<PLVMediaBitRate[]>([])
  readonly isCasting = derivedStateOf(() => this.castController.value !== undefined)
  readonly currentCastDevice = derivedStateOf(() => this.castController.value?.device)
  readonly isPlaying =
    derivedStateOf(() => this.castController.value?.listenerRegistry.playState.value === PLVMediaCastPlayState.PLAYING)
  readonly position = derivedStateOf(() => this.castController.value?.listenerRegistry.currentPosition.value)
  readonly duration = derivedStateOf(() => this.castController.value?.listenerRegistry.duration.value)
  readonly startCastEvent = new MutableEvent<PLVMediaCastController>().async(false)
  isCallingStartCast = false

  private observers: MutableObserver[] = []

  constructor(
    mediaMediator: PLVMPMediaMediator
  ) {
    this.mediaMediator = mediaMediator
    this.init()
  }

  private init() {
    watchStates(async () => {
      const mediaResource = this.mediaMediator.mediaResource.value
      const bitrate = this.mediaMediator.mediaInfoViewState.value?.bitRate
      const supportBitRates = this.mediaMediator.mediaInfoViewState.value?.supportBitRates ?? []
      const castData = new PLVMediaCastData()
      castData.mediaResource = mediaResource
      castData.bitrate = bitrate ?? undefined
      this.isMediaCastEnable.setValue(await PLVMediaCastManager.getInstance().isMediaSupportCast(castData))
      this.castSupportBitRates.setValue(supportBitRates)
    }).pushTo(this.observers)
    watchStates(() => {
      const controller = this.castController.value
      const isStopped = controller?.listenerRegistry.playState.value === PLVMediaCastPlayState.STOPPED
      if (isStopped && !this.isCallingStartCast) {
        this.reset()
      }
    }).pushTo(this.observers)
  }

  async scanDevice() {
    return PLVMediaCastManager.getInstance().scanDevices(seconds(5))
  }

  async startCast(castDevice: PLVMediaCastDevice) {
    await this.handleStartCast(
      castDevice,
      this.mediaMediator.mediaInfoViewState.value?.bitRate ?? undefined
    )
  }

  async switchBitRate(bitRate: PLVMediaBitRate) {
    await this.handleStartCast(
      this.currentCastDevice.value,
      bitRate
    )
  }

  private async handleStartCast(
    castDevice: PLVMediaCastDevice | undefined,
    bitRate: PLVMediaBitRate | undefined
  ) {
    if (!castDevice) {
      await this.stopCast()
      return
    }
    const mediaResource = this.mediaMediator.mediaResource.value
    const castData = new PLVMediaCastData()
    castData.mediaResource = mediaResource
    castData.bitrate = bitRate
    this.isCallingStartCast = true
    const result = await runCatching(PLVMediaCastManager.getInstance().startCast(castDevice, castData))
    if (result.success == false) {
      this.reset()
      throw result.error
    }
    const controller = result.data
    this.castController.setValue(controller)
    this.startCastEvent.setValue(controller)
    this.isCallingStartCast = false
  }

  async play() {
    await this.castController.value?.play()
  }

  async pause() {
    await this.castController.value?.pause()
  }

  async seek(position: Duration) {
    await this.castController.value?.seek(position)
  }

  async stopCast() {
    const controller = this.castController.value
    if (controller) {
      await PLVMediaCastManager.getInstance().stopCast(controller)
      this.reset()
    }
  }

  private reset() {
    this.castController.setValue(undefined)
    this.castBitRate.setValue(undefined)
  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}