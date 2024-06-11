import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerPlayErrorOverlayLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => [
      this.isVisible = viewState.errorOverlayLayoutVisible
    ]).pushTo(this.observers)
  }

  build() {
    Stack() {
      Column() {
        Text($r('app.string.plv_media_player_ui_component_error_hint_text'))
          .fontSize(14)
          .fontColor('#FFFFFF')

        Row() {
          Image($r('app.media.plv_media_player_restart_icon'))
            .width(16)
            .height(16)

          Text($r('app.string.plv_media_player_ui_component_error_hint_restart_text'))
            .fontSize(14)
            .fontColor('#FFFFFF')
            .margin({
              left: 5
            })
        }
        .backgroundColor('#1AFFFFFF')
        .borderRadius(16)
        .margin({
          top: 22
        })
        .padding(usePadding({
          horizontal: 16,
          vertical: 6
        }))
        .onClick(() => {
          this.mediaViewModel.restart()
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#CC000000')
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}