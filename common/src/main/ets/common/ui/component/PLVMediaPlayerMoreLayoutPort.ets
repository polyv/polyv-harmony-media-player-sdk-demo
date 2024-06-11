import {
  DependScope,
  extendArray,
  MutableObserver,
  PLVMediaBitRate,
  PLVMediaOutputMode
} from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { createId, parent, toBottomOf, toEndOf, toTopOf, usePadding } from '../../utils/arkts-no-everything'
import { PLVMediaPlayerMoreLayoutAudioModeActionView } from './PLVMediaPlayerMoreLayoutAudioModeActionView'

@Component
export struct PLVMediaPlayerMoreLayoutPort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentSpeed: number = 1
  private supportSpeeds: number[] = [0.5, 1.0, 1.5, 2.0]
  @State currentBitRate: PLVMediaBitRate | null = null
  @State supportBitRates: PLVMediaBitRate[] = []
  @State currentMediaOutputMode: PLVMediaOutputMode = PLVMediaOutputMode.AUDIO_VIDEO
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_more_action_layout_close_layout_mask_port: string = createId()
  private readonly plv_media_player_more_action_layout_container: string = createId()
  private readonly plv_media_player_more_action_close_iv_port: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'more'
    }).pushTo(this.observers)

    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.currentSpeed = viewState.speed
    }).pushTo(this.observers)

    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.currentBitRate = viewState.bitRate
      this.supportBitRates = viewState.supportBitRates
      this.currentMediaOutputMode = viewState.outputMode
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.plv_media_player_more_action_layout_close_layout_mask_port)
      .width('100%')
      .height('100%')
      .onClick(() => {
        this.controllerViewModel.popFloatActionLayout()
      })

      Column() {
        Row() {
          PLVMediaPlayerMoreLayoutAudioModeActionView()
        }

        if (this.currentBitRate !== null && this.supportBitRates.length > 0 && this.currentMediaOutputMode !== PLVMediaOutputMode.AUDIO_ONLY) {
          Row() {
            Text($r('app.string.plv_media_player_ui_component_bit_rate_hint_text_portrait'))
              .fontColor('#CC333333')
              .fontSize(12)
              .margin({
                right: 35
              })
            ForEach(this.supportBitRates, (bitRate: PLVMediaBitRate) => {
              Text(bitRate.name)
                .width(40)
                .height(17)
                .fontSize(12)
                .fontColor(this.currentBitRate?.name === bitRate.name ? '#3F76FC' : '#333333')
                .margin({
                  right: 28
                })
                .onClick(() => {
                  if (this.currentBitRate?.name !== bitRate.name) {
                    this.mediaViewModel.changeBitRate(bitRate)
                    this.controllerViewModel.popFloatActionLayout()
                  }
                })
            }, (bitRate: PLVMediaBitRate) => bitRate.name)
          }
          .margin({
            top: 20
          })
          .alignItems(VerticalAlign.Center)
        }

        Row() {
          Text($r('app.string.plv_media_player_ui_component_speed_hint_text_portrait'))
            .fontColor('#CC333333')
            .fontSize(12)
            .margin({
              right: 47
            })
          ForEach(this.supportSpeeds, (speed: number) => {
            Text(`${speed.toFixed(1)}x`)
              .width(40)
              .height(17)
              .fontSize(12)
              .fontColor(this.currentSpeed === speed ? '#3F76FC' : '#333333')
              .margin({
                right: 28
              })
              .onClick(() => {
                this.mediaViewModel.setSpeed(speed)
                this.controllerViewModel.popFloatActionLayout()
              })
          }, (speed: number) => speed.toString())
        }
        .margin({
          top: 20
        })
        .alignItems(VerticalAlign.Center)

      }
      .id(this.plv_media_player_more_action_layout_container)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(usePadding({
        horizontal: 24,
        vertical: 48
      }))
      .backgroundColor('#F7F8FA')
      .borderRadius({
        topLeft: 16,
        topRight: 16
      })
      .alignRules({
        bottom: toBottomOf(parent)
      })

      Image($r('app.media.plv_media_player_float_menu_close_icon'))
        .id(this.plv_media_player_more_action_close_iv_port)
        .width(48)
        .height(48)
        .padding(12)
        .margin({
          top: 8,
          right: 8
        })
        .alignRules({
          top: toTopOf(this.plv_media_player_more_action_layout_container),
          right: toEndOf(this.plv_media_player_more_action_layout_container)
        })
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