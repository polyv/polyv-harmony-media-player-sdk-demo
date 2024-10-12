import {PLVMediaDownloader, PLVMediaDownloadStatus} from "@polyvharmony/media-player-sdk-addon-cache-down";

export class PLVMPDownloadItemViewState {
  constructor(
    readonly downloader: PLVMediaDownloader,
    readonly progress: number,
    readonly fileSize: number,
    readonly status: PLVMediaDownloadStatus,
    readonly isVisible: boolean
  ) {
  }
}