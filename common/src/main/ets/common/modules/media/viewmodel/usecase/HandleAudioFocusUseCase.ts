import { PLVMPMediaRepo } from '../../model/PLVMPMediaRepo';
import {
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaPlayerOnAudioFocusInterruptEvent,
  PLVMediaPlayerPlayingState
} from '@polyvharmony/media-player-sdk';

export class HandleAudioFocusUseCase implements LifecycleAwareDependComponent {
  private readonly repo: PLVMPMediaRepo
  private pauseByAudioFocusInterrupted = false
  private observers: MutableObserver[] = []

  constructor(repo: PLVMPMediaRepo) {
    this.repo = repo

    this.observeAudioFocusEvent()
  }

  private observeAudioFocusEvent() {
    this.repo.player.getEventListenerRegistry()
      .onAudioFocusInterruptEvent
      .observe((event) => {
        if (event.arg === PLVMediaPlayerOnAudioFocusInterruptEvent.INTERRUPTED_TO_PAUSE) {
          this.pauseByAudioFocusInterrupted = this.repo.player.getStateListenerRegistry()
            .playingState
            .value === PLVMediaPlayerPlayingState.PLAYING
          if (this.pauseByAudioFocusInterrupted) {
            this.repo.pause()
          }
        } else if (event.arg === PLVMediaPlayerOnAudioFocusInterruptEvent.INTERRUPTED_RESUME_TO_PLAY) {
          if (this.pauseByAudioFocusInterrupted) {
            this.repo.start()
          }
          this.pauseByAudioFocusInterrupted = false
        }
      })
      .pushTo(this.observers)
  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}