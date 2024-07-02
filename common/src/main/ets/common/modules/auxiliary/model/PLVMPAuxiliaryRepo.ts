import {
  IPLVAuxiliaryMediaPlayer,
  LifecycleAwareDependComponent,
  PLVAuxiliaryMediaPlayer
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";

export class PLVMPAuxiliaryRepo implements LifecycleAwareDependComponent {

  private readonly mediaMediator: PLVMPMediaMediator

  readonly auxiliaryMediaPlayer: IPLVAuxiliaryMediaPlayer = new PLVAuxiliaryMediaPlayer()

  constructor(
    mediaMediator: PLVMPMediaMediator
  ) {
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