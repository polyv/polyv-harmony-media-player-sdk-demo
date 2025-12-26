import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerMoreActionImageView {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      let visible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.progressSliderDragging
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
      visible = visible || viewState.isMediaStopOverlayVisible()
      this.isVisible = visible
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_more_action_icon'))
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.controllerViewModel.pushFloatActionLayout('more')
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}