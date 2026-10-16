import { common } from '@kit.AbilityKit'
import { avSession } from '@kit.AVSessionKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { logger, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVBackgroundTaskManager } from './PLVBackgroundTaskManager'

const TAG = 'PLVBackgroundPlayback'

/** 同一 Ability 只保留当前视频的媒体会话，串行处理 Feed 切换和异步销毁。 */
export class PLVMediaPlayerBackgroundPlayback {
  private static nextId: number = 0
  private readonly logId: number = ++PLVMediaPlayerBackgroundPlayback.nextId
  private static queue: Promise<void> = Promise.resolve()
  private static owner: PLVMediaPlayerBackgroundPlayback | undefined
  private active: boolean = false
  private session: avSession.AVSession | undefined
  private taskRequested: boolean = false
  private observers: MutableObserver[] = []

  private readonly context: common.UIAbilityContext
  private readonly player: PLVMPMediaViewModel

  constructor(context: common.UIAbilityContext, player: PLVMPMediaViewModel) {
    this.context = context
    this.player = player
  }

  setActive(active: boolean): void {
    if (this.active === active) {
      return
    }
    this.log(`set-active ${this.active}->${active}`)
    this.active = active
    PLVMediaPlayerBackgroundPlayback.queue = PLVMediaPlayerBackgroundPlayback.queue.then(async () => {
      if (!this.active) {
        await this.release()
        return
      }
      if (PLVMediaPlayerBackgroundPlayback.owner === this) {
        return
      }
      this.log(`take-ownership previous=${PLVMediaPlayerBackgroundPlayback.owner?.logId}`)
      await PLVMediaPlayerBackgroundPlayback.owner?.release()
      PLVMediaPlayerBackgroundPlayback.owner = this
      try {
        await this.start()
      } catch (error) {
        await this.release()
        throw error
      }
    }).catch((error: Error) => {
      logger.error(TAG, `[session:${this.logId}] failed ${JSON.stringify(error)} ${error.message}`)
    })
  }

  private log(event: string): void {
    logger.info(TAG, `[session:${this.logId}] ${event}, active=${this.active}`)
  }

  private async start(): Promise<void> {
    this.log('session-create begin')
    this.session = await avSession.createAVSession(this.context, 'PLVMediaPlayer', 'video')
    this.log('session-create success')
    this.session.on('play', () => {
      this.log('system-command play')
      if (this.active) {
        this.player.start()
      }
    })
    this.session.on('pause', () => {
      this.log('system-command pause')
      if (this.active) {
        this.player.pause()
      }
    })
    await this.session.activate()
    this.log('session-activate success')
    let lastPlaying: boolean | undefined = undefined
    this.player.mediaPlayViewState.observe((state) => {
      if (lastPlaying !== state.isPlaying) {
        this.log(`player-state playing=${state.isPlaying}, state=${state.playerState}, position=${state.currentProgress}`)
        lastPlaying = state.isPlaying
      }
      this.session?.setAVPlaybackState({
        state: state.isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY
          : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        speed: state.speed
      }).catch((error: Error) => logger.error(TAG, `[session:${this.logId}] state failed ${JSON.stringify(error)} ${error.message}`))
    }).pushTo(this.observers)
    if (!this.active) {
      await this.release()
      return
    }
    const manager = PLVBackgroundTaskManager.getInstance()
    manager.setupContext(this.context)
    this.log('audio-task request')
    this.taskRequested = true
    await manager.pushBackgroundTask(backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK)
    this.log('audio-task request completed')
    if (!this.active) {
      await this.release()
    }
  }

  private async release(): Promise<void> {
    this.log(`release taskRequested=${this.taskRequested}, hasSession=${this.session !== undefined}`)
    MutableObserver.disposeAll(this.observers)
    this.observers = []
    try {
      if (this.taskRequested) {
        this.taskRequested = false
        await PLVBackgroundTaskManager.getInstance()
          .removeBackgroundTask(backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK)
      }
    } finally {
      const session = this.session
      this.session = undefined
      if (PLVMediaPlayerBackgroundPlayback.owner === this) {
        PLVMediaPlayerBackgroundPlayback.owner = undefined
      }
      if (session !== undefined) {
        try {
          await session.deactivate()
        } finally {
          await session.destroy()
          this.log('session-destroy success')
        }
      }
    }
  }
}
