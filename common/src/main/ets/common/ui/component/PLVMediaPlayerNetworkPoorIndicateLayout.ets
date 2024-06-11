import {
  DependScope,
  extendArray,
  MutableObserver,
  PLVMediaBitRate,
  PLVMediaOutputMode
} from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { usePadding } from '../../utils/arkts-no-everything'
import { isLandscape, isPortrait } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerNetworkPoorIndicateLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State alternativeBitRate: PLVMediaBitRate | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.networkPoorEvent.observe(() => {
      const supportBitRates = this.mediaViewModel.mediaInfoViewState.value?.supportBitRates
      const currentBitRate = this.mediaViewModel.mediaInfoViewState.value?.bitRate
      const outputMode = this.mediaViewModel.mediaInfoViewState.value?.outputMode
      if (!supportBitRates || !currentBitRate || outputMode === PLVMediaOutputMode.AUDIO_ONLY) {
        return
      }
      const nextDowngradeBitRate: PLVMediaBitRate | undefined = extendArray(supportBitRates)
        .filter((bitRate: PLVMediaBitRate) => bitRate.index < currentBitRate.index)
        .maxBy_ext((bitRate: PLVMediaBitRate) => bitRate.index)
      if (!nextDowngradeBitRate) {
        return
      }
      this.alternativeBitRate = nextDowngradeBitRate
      this.isVisible = true
    }).pushTo(this.observers)

    this.mediaViewModel.onChangeBitRateEvent.observe(() => {
      this.isVisible = false
    }).pushTo(this.observers)

    this.mediaViewModel.onPreparedEvent.observe(() => {
      this.isVisible = false
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      const lastFloatActionLayout = extendArray(viewState.floatActionLayouts).lastOrNull_ext()
      if ((isPortrait() && lastFloatActionLayout === 'more')
        || (isLandscape() && lastFloatActionLayout === 'bitRate')) {
        this.isVisible = false
      }
    }).pushTo(this.observers)
  }

  build() {
    if (this.isVisible) {
      Row() {
        Text() {
          Span($r('app.string.plv_media_player_ui_component_network_poor_hint_text'))
          Span($r('app.string.plv_media_player_ui_component_network_poor_switch_bitrate_action_text_prefix'))
            .fontColor('#3F76FC')
            .onClick(() => {
              this.mediaViewModel.changeBitRate(this.alternativeBitRate)
            })
          Span(this.alternativeBitRate?.name ?? "")
            .fontColor('#3F76FC')
            .onClick(() => {
              this.mediaViewModel.changeBitRate(this.alternativeBitRate)
            })
        }
        .fontColor('#FFFFFF')
        .fontSize(14)
        .margin({
          left: 8
        })

        Image($r('app.media.plv_media_player_float_menu_close_icon'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
          .margin({
            left: 8
          })
          .onClick(() => {
            this.isVisible = false
          })
      }
      .backgroundColor('#CC000000')
      .borderRadius(8)
      .padding(usePadding({
        vertical: 10,
        horizontal: 8
      }))
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}