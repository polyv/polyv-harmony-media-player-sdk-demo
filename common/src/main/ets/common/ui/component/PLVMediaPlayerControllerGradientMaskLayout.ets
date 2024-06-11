import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { createId, parent, toBottomOf, toTopOf } from '../../utils/arkts-no-everything'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerControllerGradientMaskLayout {
  maskHeight: number = 100
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_controller_gradient_mask_top: string = createId()
  private readonly plv_media_player_controller_gradient_mask_bottom: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      let visible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
        && !viewState.controllerLocking
      this.isVisible = visible
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Shape()
        .id(this.plv_media_player_controller_gradient_mask_top)
        .width('100%')
        .height(this.maskHeight)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#66000000', 0], ['#00000000', 1]]
        })
        .alignRules({
          top: toTopOf(parent)
        })

      Shape()
        .id(this.plv_media_player_controller_gradient_mask_bottom)
        .width('100%')
        .height(this.maskHeight)
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#66000000', 0], ['#00000000', 1]]
        })
        .alignRules({
          bottom: toBottomOf(parent)
        })
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}