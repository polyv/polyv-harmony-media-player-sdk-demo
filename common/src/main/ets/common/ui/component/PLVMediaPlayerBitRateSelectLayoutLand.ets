import { DependScope, extendArray, MutableObserver, PLVMediaBitRate } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { createId, parent, toCenterOf, toEndOf, toTopOf, usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerBitRateSelectLayoutLand {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentBitRate: PLVMediaBitRate | null = null
  @State supportBitRates: PLVMediaBitRate[] = []
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_bit_rate_select_layout_close_layout_mask_land: string = createId()
  private readonly plv_media_player_bit_rate_select_content: string = createId()
  private readonly plv_media_player_bit_rate_select_close_iv_land: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'bitRate'
    }).pushTo(this.observers)

    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.currentBitRate = viewState.bitRate
      this.supportBitRates = viewState.supportBitRates
    })
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.plv_media_player_bit_rate_select_layout_close_layout_mask_land)
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 90,
        colors: [['#00000000', 0], ['#cc000000', 0.5], ['#cc000000', 1]]
      })
      .responseRegion({
        width: '50%'
      })
      .onClick(() => {
        this.controllerViewModel.popFloatActionLayout()
      })

      Column() {
        ForEach(this.supportBitRates, (bitRate: PLVMediaBitRate) => {
          Text(bitRate.name)
            .fontSize(14)
            .fontColor(this.currentBitRate?.name === bitRate.name ? '#3F76FC' : '#FFFFFF')
            .margin(usePadding({
              vertical: 24
            }))
            .onClick(() => {
              if (this.currentBitRate?.name !== bitRate.name) {
                this.mediaViewModel.changeBitRate(bitRate)
                this.controllerViewModel.popFloatActionLayout()
              }
            })
        }, (bitRate: PLVMediaBitRate) => bitRate.name)
      }
      .id(this.plv_media_player_bit_rate_select_content)
      .alignRules({
        center: toCenterOf(parent),
        right: toEndOf(parent)
      })
      .margin({
        right: 167
      })

      Image($r('app.media.plv_media_player_float_menu_close_icon'))
        .id(this.plv_media_player_bit_rate_select_close_iv_land)
        .width(48)
        .height(48)
        .padding(12)
        .margin({
          top: 8,
          right: 8
        })
        .alignRules({
          top: toTopOf(parent),
          right: toEndOf(parent)
        })
        .fillColor('#99FFFFFF')
        .onClick(() => {
          this.controllerViewModel.popFloatActionLayout()
        })

    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}