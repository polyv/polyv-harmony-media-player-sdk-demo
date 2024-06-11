import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { usePadding } from '../../utils/arkts-no-everything'
import { formatDuration } from '../../utils/PLVTimeUtils'

@Component
export struct PLVMediaPlayerSeekProgressPreviewTextView {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State progress: number = 0
  @State duration: number = 0
  @State hasProgressPreviewImage: boolean = false
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear() {
    this.viewModel.mediaPlayViewState.observe((viewState) => {
      this.duration = viewState.duration
    }).pushTo(this.observers)

    this.viewModel.mediaInfoViewState.observe((viewState) => {
      this.hasProgressPreviewImage = viewState.progressPreviewImage !== null
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.progress = viewState.progressSliderDragPosition
      this.isVisible = viewState.progressSliderDragging
    }).pushTo(this.observers)
  }

  build() {
    Row() {
      Text(`${formatDuration(this.progress)}`)
        .fontColor('#FFFFFF')
        .fontSize(this.hasProgressPreviewImage ? 20 : 28)

      Text("/")
        .fontColor('#99FFFFFF')
        .fontSize(14)
        .padding(usePadding({
          horizontal: 4
        }))

      Text(`${formatDuration(this.duration)}`)
        .fontColor('#99FFFFFF')
        .fontSize(this.hasProgressPreviewImage ? 20 : 28)
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}