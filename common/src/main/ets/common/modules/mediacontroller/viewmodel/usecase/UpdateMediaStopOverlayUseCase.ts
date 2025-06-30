import { PLVMPMediaControllerRepo } from '../../model/PLVMPMediaControllerRepo';
import { LifecycleAwareDependComponent, MutableObserver, PLVMediaPlayerState } from '@polyvharmony/media-player-sdk';

export class UpdateMediaStopOverlayUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaControllerRepo

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaControllerRepo
  ) {
    this.repo = repo

    this.observeErrorState()
    this.observeCompleteState()
  }

  private observeErrorState() {
    this.repo.mediaMediator.businessErrorState?.observe((error) => {
      this.repo.mediator.businessErrorState.value = error
    }).pushTo(this.observers)
  }

  private observeCompleteState() {
    this.repo.mediaMediator.playerState?.observe((playerState) => {
      this.repo.mediator.playCompleteState.value = playerState === PLVMediaPlayerState.STATE_COMPLETED
    }).pushTo(this.observers)
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}