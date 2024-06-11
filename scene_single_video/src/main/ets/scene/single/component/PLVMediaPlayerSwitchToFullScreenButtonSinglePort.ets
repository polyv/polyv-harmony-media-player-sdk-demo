import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel, PLVOrientationManager } from 'media-player-common'

@Component
export struct PLVMediaPlayerSwitchToFullScreenButtonSinglePort {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_full_screen_icon'))
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        PLVOrientationManager.getInstance().requestOrientation('land')
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}