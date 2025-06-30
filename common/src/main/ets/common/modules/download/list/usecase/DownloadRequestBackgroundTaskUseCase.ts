import { LifecycleAwareDependComponent, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk';
import {
  PLVMediaDownloader,
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusWaiting
} from '@polyvharmony/media-player-sdk-addon-cache-down';
import { PLVBackgroundTaskManager } from '../../../../utils/PLVBackgroundTaskManager';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';

export class DownloadRequestBackgroundTaskUseCase implements LifecycleAwareDependComponent {

  private isAnyDownloading: boolean = false
  private observers: MutableObserver[] = []

  constructor() {
    watchStates(() => {
      const list = PLVMediaDownloaderManager.getInstance().downloaderList.value ?? []
      const newAnyDownloading = list.some(downloader => this.isDownloading(downloader))
      if (newAnyDownloading !== this.isAnyDownloading) {
        this.isAnyDownloading = newAnyDownloading
        if (this.isAnyDownloading) {
          PLVBackgroundTaskManager.getInstance().pushBackgroundTask(backgroundTaskManager.BackgroundMode.DATA_TRANSFER)
        } else {
          PLVBackgroundTaskManager.getInstance()
            .removeBackgroundTask(backgroundTaskManager.BackgroundMode.DATA_TRANSFER)
        }
      }
    }).pushTo(this.observers)
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