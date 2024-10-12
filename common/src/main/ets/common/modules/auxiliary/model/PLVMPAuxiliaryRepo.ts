import {
  IPLVAuxiliaryMediaPlayer,
  LifecycleAwareDependComponent,
  PLVAuxiliaryMediaPlayer
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";
import {PLVMPAuxiliaryMediator} from "../mediator/PLVMPAuxiliaryMediator";

export class PLVMPAuxiliaryRepo implements LifecycleAwareDependComponent {

  readonly mediator: PLVMPAuxiliaryMediator
  private readonly mediaMediator: PLVMPMediaMediator

  readonly auxiliaryMediaPlayer: IPLVAuxiliaryMediaPlayer = new PLVAuxiliaryMediaPlayer()

  constructor(
    mediator: PLVMPAuxiliaryMediator,
    mediaMediator: PLVMPMediaMediator
  ) {
    this.mediator = mediator
    this.mediaMediator = mediaMediator
  }

  setXComponent(component: any) {
    this.auxiliaryMediaPlayer.setXComponent(component)
  }

  bind() {
    this.mediaMediator.bindAuxiliaryPlayer?.(this.auxiliaryMediaPlayer)
  }

  unbind() {
    this.mediaMediator.unbindAuxiliaryPlayer?.(this.auxiliaryMediaPlayer)
  }

  onDestroy() {
    this.unbind()
    this.auxiliaryMediaPlayer.destroy()
  }

}