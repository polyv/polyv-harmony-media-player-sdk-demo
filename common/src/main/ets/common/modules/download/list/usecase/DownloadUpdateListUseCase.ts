import {PLVMPDownloadListRepo} from "../model/PLVMPDownloadListRepo";
import {
  PLVMediaDownloader,
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatusCompleted,
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusError,
  PLVMediaDownloadStatusNotStarted,
  PLVMediaDownloadStatusPaused,
  PLVMediaDownloadStatusWaiting
} from "@polyvharmony/media-player-sdk-addon-cache-down";
import {
  DerivedState,
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaBitRate,
  seconds,
  State
} from "@polyvharmony/media-player-sdk";
import {PLVMPDownloadListItemViewState, PLVMPDownloadListViewState} from "../viewstate/PLVMPDownloadListViewState";

export class DownloadUpdateListUseCase implements LifecycleAwareDependComponent {

  private observersAnyDownloaderStatusChanged: MutableObserver[] = []

  constructor(
    private readonly repo: PLVMPDownloadListRepo
  ) {
    PLVMediaDownloaderManager.getInstance().downloaderList.observe(() => this.updateDownloadList())
  }

  private updateDownloadList() {
    const list = PLVMediaDownloaderManager.getInstance().downloaderList.value ?? []

    MutableObserver.disposeAll(this.observersAnyDownloaderStatusChanged)
    this.observersAnyDownloaderStatusChanged = []

    list.forEach(downloader => {
      const downloading = this.isDownloading(downloader)
      const downloadCompleted = this.isDownloadCompleted(downloader)
      downloader.listenerRegistry.status.observe(() => {
        if (downloading != this.isDownloading(downloader) || downloadCompleted != this.isDownloadCompleted(downloader)) {
          this.updateDownloadList()
        }
      }).pushTo(this.observersAnyDownloaderStatusChanged)
    })

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
  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observersAnyDownloaderStatusChanged)
    this.observersAnyDownloaderStatusChanged = []
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