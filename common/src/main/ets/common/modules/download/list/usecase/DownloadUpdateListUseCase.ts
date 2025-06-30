import { PLVMPDownloadListRepo } from '../model/PLVMPDownloadListRepo';
import {
  PLVMediaDownloader,
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatusCompleted,
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusError,
  PLVMediaDownloadStatusNotStarted,
  PLVMediaDownloadStatusPaused,
  PLVMediaDownloadStatusWaiting
} from '@polyvharmony/media-player-sdk-addon-cache-down';
import {
  DerivedState,
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaBitRate,
  seconds,
  State,
  watchStates
} from '@polyvharmony/media-player-sdk';
import { PLVMPDownloadListItemViewState, PLVMPDownloadListViewState } from '../viewstate/PLVMPDownloadListViewState';

export class DownloadUpdateListUseCase implements LifecycleAwareDependComponent {
  private observers: MutableObserver[] = []

  constructor(
    private readonly repo: PLVMPDownloadListRepo
  ) {
    watchStates(() => {
      const list = PLVMediaDownloaderManager.getInstance().downloaderList.value ?? []

      const downloading = list
        .filter(it => this.isDownloading(it))
        .map((downloader) => {
          return this.convertDownloadItemState(downloader)
        })

      const downloaded = list
        .filter(it => this.isDownloadCompleted(it))
        .map(it => this.convertDownloadItemState(it))

      this.repo.mediator.downloadingList.value = new PLVMPDownloadListViewState(downloading)
      this.repo.mediator.downloadedList.value = new PLVMPDownloadListViewState(downloaded)
    }).pushTo(this.observers)
  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observers)
  }

  private isDownloading(downloader: PLVMediaDownloader): boolean {
    const status = downloader.listenerRegistry.status.value
    return status instanceof PLVMediaDownloadStatusPaused
      || status instanceof PLVMediaDownloadStatusWaiting
      || status instanceof PLVMediaDownloadStatusDownloading
      || status instanceof PLVMediaDownloadStatusError
  }

  private isDownloadCompleted(downloader: PLVMediaDownloader): boolean {
    const status = downloader.listenerRegistry.status.value
    return status instanceof PLVMediaDownloadStatusCompleted
  }

  private convertDownloadItemState(downloader: PLVMediaDownloader): State<PLVMPDownloadListItemViewState> {
    return new DerivedState(() => new PLVMPDownloadListItemViewState(
      downloader,
      downloader.listenerRegistry.vodVideoJson.value?.title ?? "",
      downloader.listenerRegistry.coverImage.value ?? null,
      downloader.listenerRegistry.downloadBitRate.value ?? PLVMediaBitRate.BITRATE_UNKNOWN,
      downloader.listenerRegistry.duration.value ?? seconds(0),
      downloader.listenerRegistry.progress.value ?? 0,
      downloader.listenerRegistry.fileSize.value ?? 0,
      downloader.listenerRegistry.status.value ?? PLVMediaDownloadStatusNotStarted.instance,
      downloader.listenerRegistry.downloadBytesPerSecond.value ?? 0
    ))
  }

}