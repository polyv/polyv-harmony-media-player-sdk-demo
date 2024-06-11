import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

@Component
export struct PLVMediaPlayerPlayCompleteManualRestartOverlayLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => [
      this.isVisible = viewState.completeOverlayLayoutVisible
    ]).pushTo(this.observers)
  }

  build() {
    Stack() {
      Column() {
        Image($r('app.media.plv_media_player_restart_icon'))
          .width(32)
          .height(32)

        Text($r('app.string.plv_media_player_ui_component_complete_hint_restart_text'))
          .fontSize(14)
          .fontColor('#99FFFFFF')
          .margin({
            top: 8
          })
      }
      .onClick(() => {
        this.mediaViewModel.restart()
      })
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