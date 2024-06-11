import {PLVMPMediaControllerRepo} from "../../model/PLVMPMediaControllerRepo";
import {
  LifecycleAwareDependComponent,
  MutableObserver,
  MutableState,
  PLVMediaPlayerBusinessErrorEnum,
  PLVMediaPlayerPlayingState,
  PLVMediaPlayerState
} from '@polyvharmony/media-player-sdk';

export class UpdateMediaStopOverlayUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaControllerRepo

  readonly businessErrorState = new MutableState<PLVMediaPlayerBusinessErrorEnum | null>(null)
  readonly playCompleteState = new MutableState<boolean>(false)

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaControllerRepo
  ) {
    this.repo = repo

    this.observeErrorState()
    this.observeCompleteState()
  }

  private observeErrorState() {
    this.repo.mediaMediator.businessErrorState?.observe(() => {
      this.updateErrorState()
    }).pushTo(this.observers)

    this.repo.mediaMediator.playingState?.observe(() => {
      this.updateErrorState()
    }).pushTo(this.observers)
  }

  private updateErrorState() {
    const error = this.repo.mediaMediator.businessErrorState?.value ?? null
    const isPlaying = this.repo.mediaMediator.playingState?.value === PLVMediaPlayerPlayingState.PLAYING

    if (error !== null && !isPlaying) {
      this.businessErrorState.value = error
    } else {
      this.businessErrorState.value = null
    }
  }

  private observeCompleteState() {
    this.repo.mediaMediator.playerState?.observe((playerState) => {
      this.playCompleteState.value = playerState === PLVMediaPlayerState.STATE_COMPLETED
    })
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}