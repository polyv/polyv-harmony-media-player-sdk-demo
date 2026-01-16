import { DependModule } from '@polyvharmony/media-player-sdk';
import { PLVMPMediaMediator } from '../../media/mediator/PLVMPMediaMediator';
import { PLVMPDanmuRepo } from '../model/PLVMPDanmuRepo';
import { PLVMPDanmuViewModel } from '../viewmodel/PLVMPDanmuViewModel';

export const danmuModule = new DependModule()

danmuModule.provide(PLVMPDanmuRepo, (scope) => new PLVMPDanmuRepo(
  scope.get(PLVMPMediaMediator)
))

danmuModule.provide(PLVMPDanmuViewModel, (scope) => new PLVMPDanmuViewModel(
  scope.get(PLVMPDanmuRepo)
))