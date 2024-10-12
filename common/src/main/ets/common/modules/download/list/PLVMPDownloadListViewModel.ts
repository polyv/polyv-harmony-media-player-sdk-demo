import {createDependScope} from "@polyvharmony/media-player-sdk";
import {internalDownloadListModule} from "./di/PLVMPDownloadListModule";
import {PLVMPDownloadListRepo} from "./model/PLVMPDownloadListRepo";
import {PLVMPDownloadListUseCases} from "./usecase/PLVMPDownloadListUseCases";

export class PLVMPDownloadListViewModel {

  // <editor-fold defaultstate="collapsed" desc="单例">

  private static readonly instance = new PLVMPDownloadListViewModel();

  private constructor() {
  }

  static getInstance() {
    return PLVMPDownloadListViewModel.instance;
  }

  // </editor-fold>

  private readonly dependScope = createDependScope(internalDownloadListModule)
  private readonly repo = this.dependScope.get(PLVMPDownloadListRepo)
  private readonly useCases = this.dependScope.get(PLVMPDownloadListUseCases)

  readonly downloadingList = this.repo.mediator.downloadingList
  readonly downloadedList = this.repo.mediator.downloadedList

}