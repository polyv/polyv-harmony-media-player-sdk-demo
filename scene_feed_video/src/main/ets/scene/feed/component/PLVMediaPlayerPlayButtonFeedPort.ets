import {
  DependScope,
  MutableObserver,
  PLVMediaPlayerOnInfoEvent,
  PLVMediaPlayerState
} from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel, PLVMPMediaViewModel } from 'media-player-common'

@Component
export struct PLVMediaPlayerPlayButtonFeedPort {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private seekButtonsEnabled: boolean = false
  private playerState: PLVMediaPlayerState = PLVMediaPlayerState.STATE_IDLE
  private isFirstFrameRendered: boolean = this.viewModel.mediaPlayViewState.value?.isPlaying === true
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((state) => {
      this.seekButtonsEnabled = state.seekButtonsEnabled
      this.updateVisibility()
    }).pushTo(this.observers)
    this.viewModel.mediaPlayViewState.observe((viewState) => {
      this.playerState = viewState.playerState
      this.updateVisibility()
    }).pushTo(this.observers)

    this.viewModel.onInfoEvent.observe((event) => {
      if (event.what === PLVMediaPlayerOnInfoEvent.MEDIA_INFO_VIDEO_RENDERING_START) {
        this.isFirstFrameRendered = true
        this.updateVisibility()
      }
    }).pushTo(this.observers)

  }

  build() {
    Image($r('app.media.plv_media_player_play_button_icon_to_play_portrait_full_screen'))
      .fillColor('#66FFFFFF')
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.viewModel.start()
      })
  }

  private updateVisibility() {
    this.isVisible = !this.seekButtonsEnabled && this.playerState === PLVMediaPlayerState.STATE_PAUSED
      && this.isFirstFrameRendered
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
