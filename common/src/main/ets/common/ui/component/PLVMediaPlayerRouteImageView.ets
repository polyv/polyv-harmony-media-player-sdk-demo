import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { PLVMPMediaControllerViewState } from '../../modules/mediacontroller/viewmodel/viewstate/PLVMPMediaControllerViewState'
import { isLandscape } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerRouteImageView {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private supportRouteCount: number = 0
  private controllerViewState: PLVMPMediaControllerViewState | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.supportRouteCount = viewState.supportRoutes.length
      this.updateVisible()
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.controllerViewState = viewState
      this.updateVisible()
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_route_icon'))
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.controllerViewModel.pushFloatActionLayout('route')
      })
  }

  private updateVisible() {
    // 弹窗除线路切换外还提供 HTTPDNS 设置；即使只有一条线路也需要保留入口。
    this.isVisible = this.supportRouteCount > 0
      && this.controllerViewState !== null
      && this.controllerViewState.controllerVisible
      && !this.controllerViewState.isMediaStopOverlayVisible()
      && !this.controllerViewState.progressSliderDragging
      && !this.controllerViewState.controllerLocking
      && !(this.controllerViewState.isFloatActionLayoutVisible() && isLandscape())
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
