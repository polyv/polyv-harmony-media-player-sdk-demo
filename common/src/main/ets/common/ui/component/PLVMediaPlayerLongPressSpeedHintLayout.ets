import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

@Component
export struct PLVMediaPlayerLongPressSpeedHintLayout {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.longPressSpeeding
    }).pushTo(this.observers)
  }

  build() {
    Row() {
      Text() {
        Span('2x')
          .fontSize(20)
        Span(' ')
          .fontSize(10)
        Span($r('app.string.plv_media_player_ui_component_long_press_speed_control_hint_text'))
          .fontSize(14)
      }
      .fontColor('#FFFFFF')
      .margin({
        top: 5,
        bottom: 9
      })

      Image($r("app.media.plv_media_player_long_press_speed_control_anim"))
        .width(28)
        .height(28)
        .margin({
          top: 7,
          bottom: 5
        })
    }
    .backgroundColor('#99000000')
    .borderRadius(20)
    .padding({
      left: 16,
      right: 12
    })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}