import {
  DependScope,
  MutableObserver,
  PLVMediaBitRate,
  PLVMediaPlayerOnInfoEvent,
  seconds
} from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerSwitchBitRateHintLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State isVisible: boolean = false
  @State toBitRate: PLVMediaBitRate | null = null
  @State switchSuccess: boolean = false
  private changeVisibleTimeoutId: number | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.onChangeBitRateEvent.observe((bitRate) => {
      this.toBitRate = bitRate
      this.switchSuccess = false
      this.showHint()
    }).pushTo(this.observers)

    this.mediaViewModel.onInfoEvent.observe((onInfo: PLVMediaPlayerOnInfoEvent) => {
      if (onInfo.what === PLVMediaPlayerOnInfoEvent.MEDIA_INFO_VIDEO_RENDERING_START) {
        this.switchSuccess = true
        this.showHint()
      }
    }).pushTo(this.observers)
  }

  build() {
    if (this.isVisible && this.toBitRate !== null) {
      Text() {
        Span(this.switchSuccess ? $r('app.string.plv_media_player_ui_component_switch_bit_rate_finish_text_pre') : $r('app.string.plv_media_player_ui_component_switch_bit_rate_start_text_pre'))
        Span(` ${this.toBitRate.name} `)
          .fontColor('#3F76FC')
        Span(this.switchSuccess ? $r('app.string.plv_media_player_ui_component_switch_bit_rate_finish_text_post') : $r('app.string.plv_media_player_ui_component_switch_bit_rate_start_text_post'))
      }
      .fontSize(14)
      .fontColor('#FFFFFF')
      .backgroundColor('#CC000000')
      .borderRadius(20)
      .padding(usePadding({
        vertical: 8,
        horizontal: 16
      }))
    }
  }

  private showHint() {
    this.isVisible = true
    if (this.changeVisibleTimeoutId !== null) {
      clearTimeout(this.changeVisibleTimeoutId)
    }
    this.changeVisibleTimeoutId = setTimeout(() => this.isVisible = false, seconds(3).toMillis())
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}