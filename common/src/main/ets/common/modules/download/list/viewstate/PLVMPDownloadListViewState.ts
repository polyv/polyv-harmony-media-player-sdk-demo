import {Duration, PLVMediaBitRate, State} from "@polyvharmony/media-player-sdk";
import {
  PLVMediaDownloader,
  PLVMediaDownloaderManager,
  PLVMediaDownloadStatus
} from "@polyvharmony/media-player-sdk-addon-cache-down";
import {customTokenRequestListener, PLVMPMediaConfig} from "../../../media/config/PLVMPMediaConfig";

export class PLVMPDownloadListViewState {
  constructor(
    readonly list: State<PLVMPDownloadListItemViewState>[] = []
  ) {
  }
}

export class PLVMPDownloadListItemViewState {
  constructor(
    readonly downloader: PLVMediaDownloader,
    readonly title: string,
    readonly coverImage: string | null,
    readonly bitRate: PLVMediaBitRate,
    readonly duration: Duration,
    readonly progress: number,
    readonly fileSize: number,
    readonly downloadStatus: PLVMediaDownloadStatus,
    readonly downloadBytesPerSecond: number
  ) {
  }

  startDownload() {
    if (PLVMPMediaConfig.useCustomToken) {
      this.downloader.listenerRegistry.vodTokenRequestListener = customTokenRequestListener
    }
    PLVMediaDownloaderManager.getInstance().startDownloader(this.downloader)
  }

  pauseDownload() {
    PLVMediaDownloaderManager.getInstance().pauseDownloader(this.downloader)
  }

  deleteDownload() {
    PLVMediaDownloaderManager.getInstance().deleteDownloadContent(this.downloader)
  }

}
