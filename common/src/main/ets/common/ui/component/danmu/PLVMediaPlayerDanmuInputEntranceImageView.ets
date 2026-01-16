import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPDanmuViewModel } from '../../../modules/danmu/viewmodel/PLVMPDanmuViewModel'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerDanmuInputEntranceImageView {
  @Consume dependScope: DependScope
  private readonly danmuViewModel = this.dependScope.get(PLVMPDanmuViewModel)
  private readonly controllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State private isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_danmu_icon'))
      .width(40)
      .height(40)
      .padding(8)
      .objectFit(ImageFit.Contain)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(async () => {
        this.controllerViewModel.changeControllerVisible(false)
        this.danmuViewModel.setInputLayoutVisible(true)
      })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
  }
}