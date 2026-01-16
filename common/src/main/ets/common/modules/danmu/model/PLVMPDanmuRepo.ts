import { PLVMPMediaMediator } from '../../media/mediator/PLVMPMediaMediator';

export class PLVMPDanmuRepo {
  constructor(
    readonly mediaMediator: PLVMPMediaMediator
  ) {
  }

  readonly danmuManager = this.mediaMediator.addonBusinessManager().danmu
}