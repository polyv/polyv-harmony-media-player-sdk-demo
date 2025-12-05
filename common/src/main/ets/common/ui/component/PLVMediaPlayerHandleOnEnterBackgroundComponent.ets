import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import common from '@ohos.app.ability.common'
import window from '@ohos.window'
import { LifecycleState, PLVComponentLifecycle } from '../../utils/PLVComponentLifecycle'
import { PLVMPPageControlViewModel } from '../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel'

/**
 * 进入后台是否自动暂停播放
 */
const AUTO_PAUSE_ON_BACKGROUND = true

@Component
export struct PLVMediaPlayerHandleOnEnterBackgroundComponent {
  @Consume dependScope: DependScope
  @Consume pageDependScope: DependScope
  private context = getContext(this) as common.UIAbilityContext
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private pageLifecycle: PLVComponentLifecycle = this.pageDependScope.get(PLVMPPageControlViewModel).pageLifecycle
  private isPausedByPageHide = false
  private windowEventObserver?: (event: window.WindowEventType) => void = undefined
  private observers: MutableObserver[] = []

  async aboutToAppear(): Promise<void> {
    const lastWindow = await window.getLastWindow(this.context)
    this.windowEventObserver = (event: window.WindowEventType) => {
      if (event === window.WindowEventType.WINDOW_SHOWN) {
        this.onWindowForeground()
      }
      if (event === window.WindowEventType.WINDOW_HIDDEN) {
        this.onWindowBackground()
      }
    }
    lastWindow.on('windowEvent', this.windowEventObserver)
    this.pageLifecycle.event.observe(event => {
      if (event.to === LifecycleState.SHOWING) {
        this.onPageForeground()
      }
      if (event.to === LifecycleState.APPEARED) {
        this.onPageBackground()
      }
    }).pushTo(this.observers)
  }

  build() {
  }

  private onWindowForeground() {
    if (this.isPausedByPageHide) {
      this.mediaViewModel.start()
      this.isPausedByPageHide = false
    }
  }

  private onPageForeground() {
    if (this.isPausedByPageHide) {
      this.mediaViewModel.start()
      this.isPausedByPageHide = false
    }
  }

  private onPageBackground() {
    if (this.isHandleAutoPause()) {
      const pauseMedia = this.mediaViewModel.mediaPlayViewState.value?.isPlaying === true
      if (pauseMedia) {
        this.mediaViewModel.pause()
        this.isPausedByPageHide = true
      }
    }
  }

  private onWindowBackground() {
    if (this.isHandleAutoPause()) {
      const pauseMedia = this.mediaViewModel.mediaPlayViewState.value?.isPlaying === true
      if (pauseMedia) {
        this.mediaViewModel.pause()
        this.isPausedByPageHide = true
      }
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