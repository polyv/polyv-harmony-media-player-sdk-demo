import { DependScope, MutableObserver, seconds } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { usePadding } from '../../utils/arkts-no-everything'
import { formatDuration } from '../../utils/PLVTimeUtils'

@Component
export struct PLVMediaPlayerAutoContinueHintLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State isVisible: boolean = false
  @State autoContinueTimestamp: number = 0
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.onAutoContinueEvent.observe((autoContinueEvent) => {
      this.autoContinueTimestamp = autoContinueEvent.startPosition
      this.isVisible = true
      setTimeout(() => this.isVisible = false, seconds(3).toMillis())
    }).pushTo(this.observers)
  }

  build() {
    if (this.isVisible) {
      Text() {
        Span($r('app.string.plv_media_player_ui_component_auto_continue_hint_pre'))
        Span(formatDuration(this.autoContinueTimestamp))
          .fontColor('#3F76FC')
        Span($r('app.string.plv_media_player_ui_component_auto_continue_hint_post'))
      }
      .fontSize(12)
      .fontColor('#FFFFFF')
      .backgroundColor('#99000000')
      .borderRadius(8)
      .padding(usePadding({
        vertical: 7,
        horizontal: 16
      }))
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}