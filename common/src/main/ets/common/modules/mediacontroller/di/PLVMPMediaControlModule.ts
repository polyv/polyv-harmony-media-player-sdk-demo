import {DependModule} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaControllerViewModel} from '../viewmodel/PLVMPMediaControllerViewModel';
import {PLVMPMediaMediator} from '../../media/mediator/PLVMPMediaMediator';
import {PLVMPMediaControllerUseCases} from "../viewmodel/usecase/PLVMPMediaControllerUseCases";
import {PLVMPMediaControllerRepo} from "../model/PLVMPMediaControllerRepo";
import {UpdateMediaStopOverlayUseCase} from "../viewmodel/usecase/UpdateMediaStopOverlayUseCase";

export const mediaControllerModule = new DependModule()

mediaControllerModule.provide(PLVMPMediaControllerRepo, (scope) => new PLVMPMediaControllerRepo(
  scope.get(PLVMPMediaMediator)
))

mediaControllerModule.provide(UpdateMediaStopOverlayUseCase, (scope) => new UpdateMediaStopOverlayUseCase(
  scope.get(PLVMPMediaControllerRepo)
))

mediaControllerModule.provide(PLVMPMediaControllerUseCases, (scope) => new PLVMPMediaControllerUseCases(
  scope.get(UpdateMediaStopOverlayUseCase)
))

mediaControllerModule.provide(PLVMPMediaControllerViewModel, (scope) => new PLVMPMediaControllerViewModel(
  scope.get(PLVMPMediaControllerRepo),
  scope.get(PLVMPMediaControllerUseCases)
))