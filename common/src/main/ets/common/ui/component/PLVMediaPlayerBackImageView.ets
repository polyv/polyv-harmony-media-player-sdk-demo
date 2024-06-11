import router from '@ohos.router'
import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape, isPortrait } from '../../utils/PLVDisplayUtils'
import { PLVOrientationManager } from '../../utils/PLVOrientationManager'

@Component
export struct PLVMediaPlayerBackImageView {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      let visible = viewState.controllerVisible
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
        && !viewState.progressSliderDragging
        && !viewState.controllerLocking
      visible = visible || viewState.isMediaStopOverlayVisible()
      this.isVisible = visible
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_back_icon'))
      .onClick(() => {
        if (isPortrait()) {
          router.back()
        } else {
          PLVOrientationManager.getInstance().requestOrientation('port');
        }
      })
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}