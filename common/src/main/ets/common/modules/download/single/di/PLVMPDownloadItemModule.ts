import {DependModule} from "@polyvharmony/media-player-sdk";
import {PLVMPDownloadItemMediator} from "../mediator/PLVMPDownloadItemMediator";
import {PLVMPDownloadItemRepo} from "../model/PLVMPDownloadItemRepo";
import {PLVMPMediaMediator} from "../../../media/mediator/PLVMPMediaMediator";
import {DownloadItemUpdateStateUseCase} from "../viewmodel/usecase/DownloadItemUpdateStateUseCase";
import {PLVMPDownloadItemUseCases} from "../viewmodel/usecase/PLVMPDownloadItemUseCases";
import {PLVMPDownloadItemViewModel} from "../viewmodel/PLVMPDownloadItemViewModel";

export const downloadItemModule = new DependModule()

downloadItemModule.provide(PLVMPDownloadItemMediator, () => new PLVMPDownloadItemMediator());

downloadItemModule.provide(PLVMPDownloadItemRepo, (scope) => new PLVMPDownloadItemRepo(
  scope.get(PLVMPDownloadItemMediator),
  scope.get(PLVMPMediaMediator)
))

downloadItemModule.provide(DownloadItemUpdateStateUseCase, (scope) => new DownloadItemUpdateStateUseCase(
  scope.get(PLVMPDownloadItemRepo)
))
downloadItemModule.provide(PLVMPDownloadItemUseCases, (scope) => new PLVMPDownloadItemUseCases(
  scope.get(DownloadItemUpdateStateUseCase)
))

downloadItemModule.provide(PLVMPDownloadItemViewModel, (scope) => new PLVMPDownloadItemViewModel(
  scope.get(PLVMPDownloadItemRepo),
  scope.get(PLVMPDownloadItemUseCases)
))