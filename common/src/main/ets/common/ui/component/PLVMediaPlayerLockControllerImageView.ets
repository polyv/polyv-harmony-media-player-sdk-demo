import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerLockControllerImageView {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State isLocking: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.progressSliderDragging
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isLocking = viewState.controllerLocking
    }).pushTo(this.observers)
  }

  build() {
    Image(this.isLocking ? $r('app.media.plv_media_player_lock_orientation_icon_locking') : $r('app.media.plv_media_player_lock_orientation_icon_no_lock'))
      .width(40)
      .height(40)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        if (this.isLocking) {
          this.controllerViewModel.lockMediaController('unlock')
        } else {
          this.controllerViewModel.lockMediaController('lock')
        }
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}