import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerPlayButton {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isPlaying: boolean = false
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.viewModel.mediaPlayViewState.observe((viewState) => {
      this.isPlaying = viewState.isPlaying
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Image(this.isPlaying ? $r('app.media.plv_media_player_play_button_icon_to_pause') : $r('app.media.plv_media_player_play_button_icon_to_play'))
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        if (this.isPlaying) {
          this.viewModel.pause()
        } else {
          this.viewModel.start()
        }
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}