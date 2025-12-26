import { DependScope, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk'
import { PLVMPCastViewModel } from '../../../modules/cast/viewmodel/PLVMPCastViewModel'
import { PLVMediaPlayerCastDeviceSelectLayout } from '../cast/widget/PLVMediaPlayerCastDeviceSelectLayout'

@Component
export struct PLVMediaPlayerMoreLayoutCastActionView {
  @Consume dependScope: DependScope
  iconColor: string = '#333333'
  textFontColor: string = '#CC333333'
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isCastEnable: boolean = false
  private readonly deviceSelectDialog = new CustomDialogController({
    builder: PLVMediaPlayerCastDeviceSelectLayout(),
    alignment: DialogAlignment.BottomEnd,
    customStyle: true
  })
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(async () => {
      this.isCastEnable = this.castViewModel.isMediaCastEnable.value ?? false
    }).pushTo(this.observers)
  }

  build() {
    if (this.isCastEnable) {
      Column() {
        Image($r('app.media.plv_media_player_controller_cast_button'))
          .width(36)
          .height(36)
          .padding(4)
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColor)

        Text($r('app.string.plv_media_player_cast_title'))
          .margin({
            top: 4
          })
          .fontColor(this.textFontColor)
          .fontSize(12)
      }
      .onClick(() => {
        this.deviceSelectDialog.open()
      })
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}