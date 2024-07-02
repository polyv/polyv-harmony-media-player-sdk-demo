import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import common from '@ohos.app.ability.common'
import window from '@ohos.window'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

/**
 * 进入后台是否自动暂停播放
 */
const AUTO_PAUSE_ON_BACKGROUND = true

@Component
export struct PLVMediaPlayerHandleOnEnterBackgroundComponent {
  @Consume dependScope: DependScope
  private context = getContext(this) as common.UIAbilityContext
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private isPausedByPageHide = false
  private windowEventObserver?: (event: window.WindowEventType) => void = undefined
  private observers: MutableObserver[] = []

  async aboutToAppear(): Promise<void> {
    const lastWindow = await window.getLastWindow(this.context)
    this.windowEventObserver = (event: window.WindowEventType) => {
      if (event === window.WindowEventType.WINDOW_SHOWN) {
        this.onResumeFromBackground()
      }
      if (event === window.WindowEventType.WINDOW_HIDDEN) {
        this.onEnterBackground()
      }
    }
    lastWindow.on('windowEvent', this.windowEventObserver)
  }

  build() {
  }

  private onEnterBackground() {
    if (this.isHandleAutoPause()) {
      this.isPausedByPageHide ||= this.mediaViewModel.mediaPlayViewState.value?.isPlaying === true
      if (this.isPausedByPageHide) {
        this.mediaViewModel.pause()
      }
    }
  }

  private onResumeFromBackground() {
    if (this.isHandleAutoPause()) {
      if (this.isPausedByPageHide) {
        this.mediaViewModel.start()
      }
      this.isPausedByPageHide = false
    }
  }

  private isHandleAutoPause(): boolean {
    if (!AUTO_PAUSE_ON_BACKGROUND) {
      return false;
    }
    return true;
  }

  async aboutToDisappear(): Promise<void> {
    const lastWindow = await window.getLastWindow(this.context)
    lastWindow.off('windowEvent', this.windowEventObserver)

    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}