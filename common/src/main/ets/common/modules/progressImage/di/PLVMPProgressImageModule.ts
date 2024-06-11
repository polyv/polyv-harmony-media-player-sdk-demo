import {DependModule} from '@polyvharmony/media-player-sdk';
import {PLVMPProgressImageLocalDataSource} from "../model/datasource/PLVMPProgressImageLocalDataSource";
import {PLVMPProgressImageNetworkDataSource} from "../model/datasource/PLVMPProgressImageNetworkDataSource";
import {PLVMPProgressImageRepo} from "../model/PLVMPProgressImageRepo";
import {PLVMPProgressImageViewModel} from "../viewmodel/PLVMPProgressImageViewModel";
import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";
import {DecodeProgressImageUseCase} from "../viewmodel/usecase/DecodeProgressImageUseCase";

export const progressImageModule = new DependModule()

progressImageModule.provide(PLVMPProgressImageLocalDataSource, () => new PLVMPProgressImageLocalDataSource())
progressImageModule.provide(PLVMPProgressImageNetworkDataSource, () => new PLVMPProgressImageNetworkDataSource())

progressImageModule.provide(PLVMPProgressImageRepo, (scope) => new PLVMPProgressImageRepo(
  scope.get(PLVMPProgressImageLocalDataSource),
  scope.get(PLVMPProgressImageNetworkDataSource),
  scope.get(PLVMPMediaMediator)
))

progressImageModule.provide(DecodeProgressImageUseCase, () => new DecodeProgressImageUseCase())

progressImageModule.provide(PLVMPProgressImageViewModel, (scope) => new PLVMPProgressImageViewModel(
  scope.get(PLVMPProgressImageRepo),
  scope.get(DecodeProgressImageUseCase)
))