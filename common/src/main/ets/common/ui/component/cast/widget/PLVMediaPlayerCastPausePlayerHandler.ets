import { PLVMediaCastPlayState } from '@polyvharmony/media-cast';
import { DependScope, derivedStateOf, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk';
import { PLVMPCastViewModel } from '../../../../modules/cast/viewmodel/PLVMPCastViewModel';
import { PLVMPMediaViewModel } from '../../../../modules/media/viewmodel/PLVMPMediaViewModel';
import { PLVMPPageControlViewModel } from '../../../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel';
import { LifecycleState } from '../../../../utils/PLVComponentLifecycle';

@Component
export struct PLVMediaPlayerCastPausePlayerHandler {
  mediaResourceIndex: number = 0
  @Consume pageDependScope: DependScope
  @Consume dependScope: DependScope
  private readonly mediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  private readonly pageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private readonly isActive = derivedStateOf(() => this.pageControlViewModel.currentItemIndex.value == this.mediaResourceIndex
    && this.pageControlViewModel.pageLifecycle.state.value == LifecycleState.SHOWING)
  private pausePlayerByCast = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.castViewModel.startCastEvent.observe(() => {
      if (this.isActive.value) {
        this.mediaViewModel.pause()
        this.pausePlayerByCast = true
      }
    }).pushTo(this.observers)

    watchStates(() => {
      const controller = this.castViewModel.castController.value
      const isStopped = controller?.listenerRegistry.playState.value === PLVMediaCastPlayState.STOPPED
      if (isStopped && !this.castViewModel.isCallingStartCast) {
        if (this.pausePlayerByCast && this.isActive.value) {
          this.mediaViewModel.start()
        }
        this.pausePlayerByCast = false
      }
    }).pushTo(this.observers)
  }

  build() {

  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}