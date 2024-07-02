import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel, PLVOrientationManager, usePadding } from 'media-player-common'

@Component
export struct PLVMediaPlayerSwitchToFullScreenButtonFeedPort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.isVisible = viewState.videoSize.width() !== 0
        && viewState.videoSize.height() !== 0
        && viewState.videoSize.width() > viewState.videoSize.height()
    }).pushTo(this.observers)
  }

  build() {
    Row({ space: 2 }) {
      Image($r('app.media.plv_media_player_full_screen_icon'))
        .width(16)
        .height(16)

      Text($r('app.string.plv_media_player_ui_component_full_screen_hint_text'))
        .fontColor('#FFFFFF')
        .fontSize(12)
    }
    .padding(usePadding({
      vertical: 5,
      horizontal: 8
    }))
    .backgroundColor('#1A000000')
    .borderRadius(28)
    .borderColor('#1AD8D8D8')
    .borderWidth(1)
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