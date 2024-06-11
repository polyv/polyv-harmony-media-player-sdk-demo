import { DependScope, MutableObserver, PLVMediaBitRate, PLVMediaOutputMode } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import {
  PLVMPMediaControllerViewState
} from '../../modules/mediacontroller/viewmodel/viewstate/PLVMPMediaControllerViewState'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerBitRateTextView {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentBitRate: PLVMediaBitRate | null = null
  private outputMode: PLVMediaOutputMode = PLVMediaOutputMode.AUDIO_VIDEO
  private controllerViewState: PLVMPMediaControllerViewState | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.currentBitRate = viewState.bitRate
      this.outputMode = viewState.outputMode
      this.updateVisible()
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.controllerViewState = viewState
      this.updateVisible()
    }).pushTo(this.observers)
  }

  build() {
    Text(this.currentBitRate?.name ?? "")
      .fontSize(14)
      .fontColor('#FFFFFF')
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.controllerViewModel.pushFloatActionLayout('bitRate')
      })
  }

  private updateVisible() {
    this.isVisible = this.controllerViewState !== null
      && this.controllerViewState.controllerVisible
      && !this.controllerViewState.isMediaStopOverlayVisible()
      && !this.controllerViewState.progressSliderDragging
      && !this.controllerViewState.controllerLocking
      && !(this.controllerViewState.isFloatActionLayoutVisible() && isLandscape())
      && this.currentBitRate !== null
      && this.outputMode !== PLVMediaOutputMode.AUDIO_ONLY
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}