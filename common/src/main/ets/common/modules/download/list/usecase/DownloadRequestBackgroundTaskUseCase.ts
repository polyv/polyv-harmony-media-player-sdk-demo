import {LifecycleAwareDependComponent, MutableObserver} from '@polyvharmony/media-player-sdk';
import {
  PLVMediaDownloader,
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusWaiting
} from '@polyvharmony/media-player-sdk-addon-cache-down';
import {PLVBackgroundTaskManager} from '../../../../utils/PLVBackgroundTaskManager';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';

export class DownloadRequestBackgroundTaskUseCase implements LifecycleAwareDependComponent {

  private isAnyDownloading: boolean = false
  private observers: MutableObserver[] = []

  constructor() {
    PLVMediaDownloaderManager.getInstance().downloaderList.observe(() => this.onDownloaderUpdated())
  }

  private onDownloaderUpdated() {
    const list = PLVMediaDownloaderManager.getInstance().downloaderList.value ?? []

    MutableObserver.disposeAll(this.observers)
    this.observers = []

    list.forEach(downloader => {
      const downloading = this.isDownloading(downloader)
      downloader.listenerRegistry.status.observe(() => {
        if (downloading != this.isDownloading(downloader)) {
          this.onDownloaderUpdated()
        }
      }).pushTo(this.observers)
    })

    const newAnyDownloading = list.some(downloader => this.isDownloading(downloader))

    if (newAnyDownloading !== this.isAnyDownloading) {
      this.isAnyDownloading = newAnyDownloading
      if (this.isAnyDownloading) {
        PLVBackgroundTaskManager.getInstance().pushBackgroundTask(backgroundTaskManager.BackgroundMode.DATA_TRANSFER)
      } else {
        PLVBackgroundTaskManager.getInstance().removeBackgroundTask(backgroundTaskManager.BackgroundMode.DATA_TRANSFER)
      }
    }

  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

  private isDownloading(downloader: PLVMediaDownloader): boolean {
    const status = downloader.listenerRegistry.status.value
    return status instanceof PLVMediaDownloadStatusWaiting
      || status instanceof PLVMediaDownloadStatusDownloading
  }

}