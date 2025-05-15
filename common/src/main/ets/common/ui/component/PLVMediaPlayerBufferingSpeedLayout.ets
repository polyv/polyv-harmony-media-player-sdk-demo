import {
  createDebounce,
  Debounce,
  delay,
  DependScope,
  MutableObserver,
  PLVMediaPlayerState
} from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'

@Component
export struct PLVMediaPlayerBufferingSpeedLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State isVisible: boolean = false
  @State speedText: string = ""
  private isBuffering: boolean = false
  private isPreparing: boolean = false
  private debounce: Debounce = createDebounce({ timeout: 500 })
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.isBuffering = viewState.isBuffering
      this.updateVisible()
      this.speedText = this.updateSpeedText(viewState.bufferingSpeed)
    }).pushTo(this.observers)

    this.mediaViewModel.playerState.observe((playerState: PLVMediaPlayerState) => {
      this.isPreparing = playerState === PLVMediaPlayerState.STATE_PREPARING
      this.updateVisible()
    }).pushTo(this.observers)
  }

  build() {
    if (this.isVisible) {
      Stack() {
        Column() {
          Text(this.speedText)
            .fontSize(14)
            .fontColor('#FFFFFF')
          Text($r('app.string.plv_media_player_ui_component_buffering_speed_hint_text'))
            .fontSize(14)
            .fontColor('#FFFFFF')
            .margin({
              top: 12
            })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#33000000')
    }
  }

  private async updateVisible() {
    if (!this.isBuffering && !this.isPreparing) {
      this.isVisible = false
      return
    }
    if (!this.isVisible) {
      await delay(500)
    }
    this.debounce.run(() => {
      this.isVisible = this.isBuffering || this.isPreparing
    })
  }

  private updateSpeedText(speed: number): string {
    if (speed < 1 << 10) {
      return `${speed.toFixed(0)}B/S`
    } else if (speed < 1 << 20) {
      return `${(speed / (1 << 10)).toFixed(1)}KB/S`
    } else {
      return `${(speed / (1 << 20)).toFixed(1)}MB/S`
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}