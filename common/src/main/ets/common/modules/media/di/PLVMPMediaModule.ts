import {DependModule} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaRepo} from '../model/PLVMPMediaRepo';
import {PLVMPMediaViewModel} from '../viewmodel/PLVMPMediaViewModel';
import {PLVMPMediaUseCases} from '../viewmodel/usecase/PLVMPMediaUseCases';
import {UpdateMediaStateUseCase} from '../viewmodel/usecase/UpdateMediaStateUseCase';
import {PLVMPMediaMediator} from '../mediator/PLVMPMediaMediator';
import {ObserveNetworkPoorUseCase} from "../viewmodel/usecase/ObserveNetworkPoorUseCase";
import {UpdateBufferingSpeedUseCase} from "../viewmodel/usecase/UpdateBufferingSpeedUseCase";
import {HandleAudioFocusUseCase} from "../viewmodel/usecase/HandleAudioFocusUseCase";

export const mediaModule = new DependModule()

mediaModule.provide(PLVMPMediaMediator, () => new PLVMPMediaMediator())

mediaModule.provide(PLVMPMediaRepo, (scope) => new PLVMPMediaRepo(
  scope.get(PLVMPMediaMediator)
))

mediaModule.provide(HandleAudioFocusUseCase, (scope) => new HandleAudioFocusUseCase(
  scope.get(PLVMPMediaRepo)
))
mediaModule.provide(UpdateBufferingSpeedUseCase, (scope) => new UpdateBufferingSpeedUseCase(
  scope.get(PLVMPMediaRepo)
))
mediaModule.provide(UpdateMediaStateUseCase, (scope) => new UpdateMediaStateUseCase(
  scope.get(PLVMPMediaRepo),
  scope.get(UpdateBufferingSpeedUseCase)
))
mediaModule.provide(ObserveNetworkPoorUseCase, (scope) => new ObserveNetworkPoorUseCase(
  scope.get(PLVMPMediaRepo)
))
mediaModule.provide(PLVMPMediaUseCases, (scope) => new PLVMPMediaUseCases(
  scope.get(HandleAudioFocusUseCase),
  scope.get(UpdateMediaStateUseCase),
  scope.get(ObserveNetworkPoorUseCase),
  scope.get(UpdateBufferingSpeedUseCase)
))

mediaModule.provide(PLVMPMediaViewModel, (scope) => new PLVMPMediaViewModel(
  scope.get(PLVMPMediaRepo),
  scope.get(PLVMPMediaUseCases)
))

mediaModule.afterCreate(PLVMPMediaMediator, (scope) => {
  scope.get(PLVMPMediaViewModel)
})