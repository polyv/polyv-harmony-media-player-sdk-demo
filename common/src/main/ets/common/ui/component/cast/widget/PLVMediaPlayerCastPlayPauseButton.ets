import { DependScope, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk'
import { PLVMPCastViewModel } from '../../../../modules/cast/viewmodel/PLVMPCastViewModel'

@Component
export struct PLVMediaPlayerCastPlayPauseButton {
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isPlaying: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(() => {
      this.isPlaying = this.castViewModel.isPlaying.value ?? false
    }).pushTo(this.observers)
  }

  build() {
    Image(this.isPlaying ? $r('app.media.plv_media_player_play_button_icon_to_pause') : $r('app.media.plv_media_player_play_button_icon_to_play'))
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        if (this.isPlaying) {
          this.castViewModel.pause()
        } else {
          this.castViewModel.play()
        }
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
  }
}