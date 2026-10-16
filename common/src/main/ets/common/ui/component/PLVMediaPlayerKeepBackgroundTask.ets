import { logger, DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { AbilityLifecycleCallback, common, UIAbility } from '@kit.AbilityKit'
import window from '@ohos.window'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPPageControlViewModel } from '../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel'
import { LifecycleState } from '../../utils/PLVComponentLifecycle'
import { PLVMediaPlayerBackgroundPlayback } from '../../utils/PLVMediaPlayerBackgroundPlayback'

const TAG = 'PLVBackgroundPlayback'

/** 后台音频播放、系统媒体控制以及关闭后台播放时的自动暂停/恢复。 */
@Component
export struct PLVMediaPlayerKeepBackgroundTask {
  @Consume dependScope: DependScope
  @Consume pageDependScope: DependScope
  @Prop @Watch('updateBackgroundPlayback') backgroundAudioPlaybackEnabled: boolean = true
  // 单视频不传索引；Feed 只有当前项可以申请任务或响应系统媒体控制。
  mediaResourceIndex?: number
  private context = getContext(this) as common.UIAbilityContext
  private player: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private page: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private playback = new PLVMediaPlayerBackgroundPlayback(this.context, this.player)
  private lifecycleCallbackId: number = -1
  private observers: MutableObserver[] = []
  private appeared: boolean = false
  private playbackPageActive: boolean = true
  private abilityForeground: boolean = true
  private pausedByLifecycle: boolean = false

  aboutToAppear(): void {
    this.appeared = true
    this.playbackPageActive = this.page.playbackPageActive.value ?? true
    this.logState('appear')
    this.lifecycleCallbackId = this.context.getApplicationContext().on('abilityLifecycle',
      new PLVMediaPlayerAbilityLifecycleCallback(this.context, () => {
        this.abilityForeground = false
        this.logState('ability-background')
        if (!this.backgroundAudioPlaybackEnabled) {
          this.pauseForLifecycle('background-disabled')
        }
      }, () => {
        this.abilityForeground = true
        this.logState('ability-foreground')
        this.resumeForLifecycle()
      }))
    this.page.pageLifecycle.event.observe(event => {
      this.logState(`page-event ${event.from}->${event.to}, windowHidden=${event.isWindowHidden}`)
      // 页面隐藏（包括下载页覆盖）不改变播放权；页面销毁仍需暂停和清理。
      if (event.to === LifecycleState.INITIALIZED) {
        this.playbackPageActive = false
        this.pauseForLifecycle('page-destroyed')
        this.updateBackgroundPlayback()
      }
    }).pushTo(this.observers)
    this.page.playbackPageActive.observe(active => {
      this.playbackPageActive = active
      this.logState('playback-page-changed')
      if (active) {
        this.resumeForLifecycle()
      } else {
        this.pauseForLifecycle('another-playback-page')
      }
      this.updateBackgroundPlayback()
    }).pushTo(this.observers)
    this.page.currentItemIndex.observe(() => {
      this.logState('feed-index-changed')
      if (!this.isCurrentItem()) {
        this.pausedByLifecycle = false
      }
      this.updateBackgroundPlayback()
    }).pushTo(this.observers)
    this.updateBackgroundPlayback()
  }

  build() {
  }

  private isCurrentItem(): boolean {
    return this.mediaResourceIndex === undefined || this.mediaResourceIndex === this.page.currentItemIndex.value
  }

  private updateBackgroundPlayback(): void {
    this.logState('update-background-playback')
    this.playback.setActive(this.appeared && this.playbackPageActive && this.isCurrentItem()
      && this.backgroundAudioPlaybackEnabled)
    if (!this.abilityForeground && !this.backgroundAudioPlaybackEnabled) {
      this.pauseForLifecycle('background-disabled')
    }
  }

  private pauseForLifecycle(reason: string): void {
    this.logState(`pause-check reason=${reason}`)
    if (this.isCurrentItem() && this.player.mediaPlayViewState.value?.isPlaying === true) {
      this.pausedByLifecycle = true
      this.logState(`pause reason=${reason}`)
      this.player.pause()
    }
  }

  private resumeForLifecycle(): void {
    if (this.playbackPageActive && this.isCurrentItem() && this.abilityForeground && this.pausedByLifecycle) {
      this.pausedByLifecycle = false
      this.logState('resume-by-lifecycle')
      this.player.start()
    }
  }

  private logState(event: string): void {
    logger.info(TAG, `[component] ${event}, item=${this.mediaResourceIndex ?? 'single'}, current=${this.page.currentItemIndex.value}, enabled=${this.backgroundAudioPlaybackEnabled}, appeared=${this.appeared}, playbackPageActive=${this.playbackPageActive}, foreground=${this.abilityForeground}, playing=${this.player.mediaPlayViewState.value?.isPlaying}, pausedByLifecycle=${this.pausedByLifecycle}`)
  }

  aboutToDisappear(): void {
    this.logState('disappear')
    this.appeared = false
    this.pausedByLifecycle = false
    MutableObserver.disposeAll(this.observers)
    this.observers = []
    this.playback.setActive(false)
    if (this.lifecycleCallbackId >= 0) {
      this.context.getApplicationContext().off('abilityLifecycle', this.lifecycleCallbackId)
        .catch((error: Error) => logger.error(TAG, `PLVMediaPlayer lifecycle: ${error.message}`))
      this.lifecycleCallbackId = -1
    }
  }
}

class PLVMediaPlayerAbilityLifecycleCallback extends AbilityLifecycleCallback {
  private readonly context: common.UIAbilityContext
  private readonly background: () => void
  private readonly foreground: () => void

  constructor(context: common.UIAbilityContext, background: () => void, foreground: () => void) {
    super()
    this.context = context
    this.background = background
    this.foreground = foreground
  }

  onAbilityCreate(ability: UIAbility): void {}
  onWindowStageCreate(ability: UIAbility, stage: window.WindowStage): void {}
  onWindowStageActive(ability: UIAbility, stage: window.WindowStage): void {}
  onWindowStageInactive(ability: UIAbility, stage: window.WindowStage): void {}
  onWindowStageDestroy(ability: UIAbility, stage: window.WindowStage): void {}
  onAbilityDestroy(ability: UIAbility): void {}
  onAbilityContinue(ability: UIAbility): void {}

  onAbilityForeground(ability: UIAbility): void {
    logger.info(TAG, `[ability] foreground matched=${ability.context === this.context}, name=${ability.context.abilityInfo.name}`)
    if (ability.context === this.context) {
      this.foreground()
    }
  }

  onAbilityBackground(ability: UIAbility): void {
    logger.info(TAG, `[ability] background matched=${ability.context === this.context}, name=${ability.context.abilityInfo.name}`)
    if (ability.context === this.context) {
      this.background()
    }
  }
}
