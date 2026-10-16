import {common, wantAgent} from '@kit.AbilityKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { extendArray, isNullOrUndefined, logger, MutableState } from '@polyvharmony/media-player-sdk'

const TAG = 'PLVBackgroundPlayback'

export class PLVBackgroundTaskManager {

  private static readonly instance = new PLVBackgroundTaskManager()

  private constructor() {
  }

  static getInstance() {
    return PLVBackgroundTaskManager.instance
  }

  runningBackgroundTaskType: MutableState<backgroundTaskManager.BackgroundMode | null> = new MutableState(null)

  private refContext: common.UIAbilityContext | null = null
  private taskQueue: Promise<void> = Promise.resolve()
  private backgroundTasks: backgroundTaskManager.BackgroundMode[] = []

  setupContext(context: common.UIAbilityContext) {
    this.refContext = context
  }

  pushBackgroundTask(type: backgroundTaskManager.BackgroundMode): Promise<void> {
    logger.info(TAG, `[task] push type=${type}, running=${this.runningBackgroundTaskType.value}`)
    this.backgroundTasks.push(type)
    return this.scheduleUpdate()
  }

  removeBackgroundTask(type: backgroundTaskManager.BackgroundMode): Promise<void> {
    logger.info(TAG, `[task] remove type=${type}, running=${this.runningBackgroundTaskType.value}`)
    extendArray(this.backgroundTasks).remove_ext(type)
    return this.scheduleUpdate()
  }

  private scheduleUpdate(): Promise<void> {
    const update = this.taskQueue.then(() => this.updateCurrentRunningBackgroundTask())
    this.taskQueue = update.catch((error: Error) => {
      logger.error(TAG, `[task] failed ${JSON.stringify(error)} ${error.message}`)
    })
    return update
  }

  private async updateCurrentRunningBackgroundTask(): Promise<void> {
    // 音频播放优先；释放后恢复仍在等待的下载任务。
    const audio = backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK
    const next = this.backgroundTasks.includes(audio) ? audio : (this.backgroundTasks[0] ?? null)
    logger.info(TAG, `[task] update requested=${this.backgroundTasks.join(',')}, running=${this.runningBackgroundTaskType.value}, next=${next}`)
    if (this.runningBackgroundTaskType.value === next) {
      return
    }
    if (!isNullOrUndefined(this.runningBackgroundTaskType.value)) {
      await this.stopBackgroundTask()
    }
    if (next !== null) {
      await this.startBackgroundTask(next)
    }
  }

  private async startBackgroundTask(type: backgroundTaskManager.BackgroundMode) {
    if (this.refContext === null) {
      logger.warn(TAG, '[task] skipped: context missing')
      return
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.refContext.abilityInfo.bundleName,
          abilityName: this.refContext.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    const wantAgentObject = await wantAgent.getWantAgent(wantAgentInfo)
    logger.info(TAG, `[task] start begin type=${type}`)
    await backgroundTaskManager.startBackgroundRunning(this.refContext, type, wantAgentObject)
    this.runningBackgroundTaskType.setValue(type)
    logger.info(TAG, `[task] start success type=${type}`)
  }

  private async stopBackgroundTask() {
    if (this.refContext === null) {
      logger.warn(TAG, '[task] skipped: context missing')
      return
    }
    logger.info(TAG, `[task] stop begin type=${this.runningBackgroundTaskType.value}`)
    await backgroundTaskManager.stopBackgroundRunning(this.refContext)
    this.runningBackgroundTaskType.setValue(null)
    logger.info(TAG, '[task] stop success')
  }

  async destroy() {
    this.backgroundTasks = []
    await this.scheduleUpdate()
    this.refContext = null
  }

}