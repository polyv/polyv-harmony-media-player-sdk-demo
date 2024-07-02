import {DependModule} from '@polyvharmony/media-player-sdk';
import {PLVMPAuxiliaryViewModel} from "../viewmodel/PLVMPAuxiliaryViewModel";
import {PLVMPAuxiliaryRepo} from "../model/PLVMPAuxiliaryRepo";
import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";
import {PLVMPAuxiliaryUseCases} from "../viewmodel/usecases/PLVMPAuxiliaryUseCases";
import {AuxiliaryUpdateMediaStateUseCase} from "../viewmodel/usecases/AuxiliaryUpdateMediaStateUseCase";
import {AuxiliaryBeforePlayListener} from "../viewmodel/usecases/AuxiliaryBeforePlayListener";

export const auxiliaryModule = new DependModule()

auxiliaryModule.provide(PLVMPAuxiliaryRepo, (scope) => new PLVMPAuxiliaryRepo(
  scope.get(PLVMPMediaMediator)
))

auxiliaryModule.provide(AuxiliaryBeforePlayListener, () => new AuxiliaryBeforePlayListener())
auxiliaryModule.provide(AuxiliaryUpdateMediaStateUseCase, (scope) => new AuxiliaryUpdateMediaStateUseCase(
  scope.get(PLVMPAuxiliaryRepo)
))
auxiliaryModule.provide(PLVMPAuxiliaryUseCases, (scope) => new PLVMPAuxiliaryUseCases(
  scope.get(AuxiliaryBeforePlayListener),
  scope.get(AuxiliaryUpdateMediaStateUseCase)
))

auxiliaryModule.provide(PLVMPAuxiliaryViewModel, (scope) => new PLVMPAuxiliaryViewModel(
  scope.get(PLVMPAuxiliaryRepo),
  scope.get(PLVMPAuxiliaryUseCases)
))