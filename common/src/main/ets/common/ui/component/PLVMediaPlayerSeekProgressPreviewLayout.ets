import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { PLVMPProgressImageViewModel } from '../../modules/progressImage/viewmodel/PLVMPProgressImageViewModel'
import { PLVMediaPlayerSeekProgressPreviewTextView } from './PLVMediaPlayerSeekProgressPreviewTextView'
import image from '@ohos.multimedia.image'

@Component
export struct PLVMediaPlayerSeekProgressPreviewLayout {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private progressImageViewModel: PLVMPProgressImageViewModel = this.dependScope.get(PLVMPProgressImageViewModel)
  @State isVisible: boolean = false
  @State progressImagePixelMap: image.PixelMap | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.progressSliderDragging
      if (viewState.progressSliderDragging) {
        this.progressImageViewModel.updateProgressImage(viewState.progressSliderDragPosition)
      }
    }).pushTo(this.observers)

    this.progressImageViewModel.progressImage.observe((pixelMap: image.PixelMap | null) => {
      this.progressImagePixelMap = pixelMap
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      if (this.progressImagePixelMap !== null) {
        Image(this.progressImagePixelMap)
          .width(160)
          .height(90)
          .margin({
            bottom: 4
          })
          .borderRadius(8)
      }
      PLVMediaPlayerSeekProgressPreviewTextView()
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}