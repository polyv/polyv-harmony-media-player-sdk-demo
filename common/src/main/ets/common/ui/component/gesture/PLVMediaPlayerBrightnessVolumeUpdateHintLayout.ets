import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { usePadding } from '../../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerBrightnessVolumeUpdateHintLayout {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentBrightness: number = 50
  @State currentVolume: number = 100
  @State updateType: 'brightness' | 'volume' = 'brightness'
  private hideTimeoutId: number | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.brightnessUpdateEvent.observe((brightness) => {
      this.update('brightness', brightness * 100)
    }).pushTo(this.observers)

    this.controllerViewModel.volumeUpdateEvent.observe((volume) => {
      this.update('volume', volume)
    }).pushTo(this.observers)
  }

  build() {
    Row() {
      Image(this.updateType === 'brightness' ? $r('app.media.plv_media_player_brightness_hint_icon') : $r('app.media.plv_media_player_volume_hint_icon'))
        .width(24)
        .height(24)

      Progress({
        value: this.updateType === 'brightness' ? this.currentBrightness : this.currentVolume,
        total: 100,
        type: ProgressType.Linear
      })
        .width(100)
        .height(2)
        .borderRadius(1)
        .color('#3F76FC')
        .backgroundColor('#66FFFFFF')
        .margin({
          left: 12,
          right: 8
        })
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .padding(usePadding({
      horizontal: 16,
      vertical: 8
    }))
    .backgroundColor('#99000000')
    .borderRadius(20)
  }

  private update(type: 'brightness' | 'volume', value: number) {
    this.updateType = type
    if (type === 'brightness') {
      this.currentBrightness = value
    } else {
      this.currentVolume = value
    }

    this.isVisible = true
    if (this.hideTimeoutId) {
      clearTimeout(this.hideTimeoutId)
    }
    this.hideTimeoutId = setTimeout(() => this.isVisible = false, 2000)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
    if (this.hideTimeoutId) {
      clearTimeout(this.hideTimeoutId)
    }
    this.hideTimeoutId = null
  }
}