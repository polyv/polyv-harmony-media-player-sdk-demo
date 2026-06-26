import { PLVMPDownloadItemRepo } from '../../model/PLVMPDownloadItemRepo';
import {
  LifecycleAwareDependComponent,
  MutableObserver,
  MutableState,
  PLVMediaBitRate,
  runCatching,
  watchStates
} from '@polyvharmony/media-player-sdk';
import { PLVMPDownloadItemViewState } from '../viewstate/PLVMPDownloadItemViewState';
import {
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatusNotStarted
} from '@polyvharmony/media-player-sdk-addon-cache-down';

export class DownloadItemUpdateStateUseCase implements LifecycleAwareDependComponent {

  constructor(
    readonly repo: PLVMPDownloadItemRepo
  ) {
    this.init()
  }

  private readonly downloadActionVisibleState = new MutableState<boolean>(true)
  private observers: MutableObserver[] = []

  private init() {
    watchStates(() => {
      const mediaResource = this.repo.mediaMediator.mediaResource.value
      const bitRate = this.repo.mediaMediator.mediaInfoViewState.value?.bitRate ?? PLVMediaBitRate.BITRATE_AUTO
      if (mediaResource === undefined) {
        return this.repo.mediator.downloadItem.setValue(null)
      }
      const downloaderResult = runCatching(() => PLVMediaDownloaderManager.getInstance().getDownloader(mediaResource, bitRate))
      if (downloaderResult.success === false) {
        return this.repo.mediator.downloadItem.setValue(null)
      }
      const downloader = downloaderResult.data
      const downloadItem = new PLVMPDownloadItemViewState(
        downloader,
        downloader.listenerRegistry.progress.value ?? 0,
        downloader.listenerRegistry.fileSize.value ?? 0,
        downloader.listenerRegistry.status.value ?? PLVMediaDownloadStatusNotStarted.instance,
        this.downloadActionVisibleState.value ?? true
      )
      this.repo.mediator.downloadItem.setValue(downloadItem)
    }).pushTo(this.observers)
  }

  setDownloadActionVisible(isVisible: boolean) {
    this.downloadActionVisibleState.setValue(isVisible)
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}