import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerTitleTextView {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State title: string = ""
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.viewModel.mediaInfoViewState.observe((viewState) => {
      this.title = viewState.title
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      let visible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
        && !viewState.progressSliderDragging
        && !viewState.controllerLocking;
      this.isVisible = visible
    }).pushTo(this.observers)
  }

  build() {
    Text(this.title)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .ellipsisMode(EllipsisMode.END)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}