import {DependModule} from "@polyvharmony/media-player-sdk";
import {PLVMPDownloadListMediator} from "../mediator/PLVMPDownloadListMediator";
import {PLVMPDownloadListRepo} from "../model/PLVMPDownloadListRepo";
import {DownloadRequestBackgroundTaskUseCase} from '../usecase/DownloadRequestBackgroundTaskUseCase';
import {DownloadUpdateListUseCase} from "../usecase/DownloadUpdateListUseCase";
import {PLVMPDownloadListUseCases} from "../usecase/PLVMPDownloadListUseCases";

export const internalDownloadListModule = new DependModule()

internalDownloadListModule.provide(PLVMPDownloadListMediator, () => new PLVMPDownloadListMediator());

internalDownloadListModule.provide(PLVMPDownloadListRepo, (scope) => new PLVMPDownloadListRepo(
  scope.get(PLVMPDownloadListMediator)
))

internalDownloadListModule.provide(DownloadUpdateListUseCase, (scope) => new DownloadUpdateListUseCase(
  scope.get(PLVMPDownloadListRepo)
))
internalDownloadListModule.provide(DownloadRequestBackgroundTaskUseCase, () => new DownloadRequestBackgroundTaskUseCase())
internalDownloadListModule.provide(PLVMPDownloadListUseCases, (scope) => new PLVMPDownloadListUseCases(
  scope.get(DownloadUpdateListUseCase),
  scope.get(DownloadRequestBackgroundTaskUseCase)
))