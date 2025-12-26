import { DependModule } from '@polyvharmony/media-player-sdk';
import { PLVMPMediaMediator } from '../../media/mediator/PLVMPMediaMediator';
import { PLVMPCastViewModel } from '../viewmodel/PLVMPCastViewModel';

export const castModule = new DependModule()

castModule.provide(PLVMPCastViewModel, (scope) => new PLVMPCastViewModel(
  scope.get(PLVMPMediaMediator)
))