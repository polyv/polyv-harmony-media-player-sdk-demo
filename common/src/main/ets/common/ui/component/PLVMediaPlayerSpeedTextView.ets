import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerSpeedTextView {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentSpeed: number = 1.0
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.currentSpeed = viewState.speed
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.progressSliderDragging
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Text(`${this.currentSpeed.toFixed(1)}x`)
      .fontSize(14)
      .fontColor('#FFFFFF')
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.controllerViewModel.pushFloatActionLayout('speed')
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}