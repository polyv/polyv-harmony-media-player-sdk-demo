import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { usePadding } from '../../../utils/arkts-no-everything'
import { isLandscape } from '../../../utils/PLVDisplayUtils'
import { formatDuration } from '../../../utils/PLVTimeUtils'

@Component
export struct PLVMediaPlayerProgressTextView {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State progress: number = 0
  @State duration: number = 0
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear() {
    this.viewModel.mediaPlayViewState.observe((viewState) => {
      this.progress = viewState.currentProgress
      this.duration = viewState.duration
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Row() {
      Text(`${formatDuration(this.progress)}`)
        .fontColor('#FFFFFF')
        .fontSize(14)

      Text("/")
        .fontColor('#99FFFFFF')
        .fontSize(12)
        .padding(usePadding({
          horizontal: 4
        }))

      Text(`${formatDuration(this.duration)}`)
        .fontColor('#99FFFFFF')
        .fontSize(14)
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}