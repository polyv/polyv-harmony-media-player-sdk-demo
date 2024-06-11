import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { LifecycleState, PLVComponentLifecycle } from '../../utils/PLVComponentLifecycle'

/**
 * 进入后台时自动暂停播放
 */
@Component
export struct PLVMediaPlayerHandleOnEnterBackgroundComponent {
  @Consume dependScope: DependScope
  @Consume pageLifecycle: PLVComponentLifecycle
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private isPausedByPageHide = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.pageLifecycle.state.observe((state) => {
      if (state < LifecycleState.SHOWING && !this.isPausedByPageHide) {
        this.isPausedByPageHide = this.mediaViewModel.mediaPlayViewState.value?.isPlaying === true
        if (this.isPausedByPageHide) {
          this.mediaViewModel.pause()
        }
      }
      if (state >= LifecycleState.SHOWING && this.isPausedByPageHide) {
        this.mediaViewModel.start()
        this.isPausedByPageHide = false
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