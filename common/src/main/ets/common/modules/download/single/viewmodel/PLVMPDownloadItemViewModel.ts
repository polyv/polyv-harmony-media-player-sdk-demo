import {PLVMPDownloadItemRepo} from "../model/PLVMPDownloadItemRepo";
import {PLVMPDownloadItemUseCases} from "./usecase/PLVMPDownloadItemUseCases";
import {PLVMediaDownloaderManager} from "@polyvharmony/media-player-sdk-addon-cache-down";
import {PLVMPDownloadListViewModel} from '../../list/PLVMPDownloadListViewModel';

export class PLVMPDownloadItemViewModel {

  constructor(
    readonly repo: PLVMPDownloadItemRepo,
    readonly useCases: PLVMPDownloadItemUseCases
  ) {
  }

  readonly downloadItem = this.repo.mediator.downloadItem

  startDownload() {
    // 加载 DownloadRequestBackgroundTask 确保后台任务
    PLVMPDownloadListViewModel.getInstance()

    const downloader = this.repo.mediator.downloadItem.value?.downloader
    if (downloader === undefined) {
      return
    }
    PLVMediaDownloaderManager.getInstance().startDownloader(downloader)
  }

  pauseDownload() {
    const downloader = this.repo.mediator.downloadItem.value?.downloader
    if (downloader === undefined) {
      return
    }
    PLVMediaDownloaderManager.getInstance().pauseDownloader(downloader)
  }

  setDownloadActionVisible(isVisible: boolean) {
    this.useCases.downloadItemUpdateStateUseCase.setDownloadActionVisible(isVisible)
  }

}