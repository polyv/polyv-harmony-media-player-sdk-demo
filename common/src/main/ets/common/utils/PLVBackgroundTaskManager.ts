import {common, wantAgent} from '@kit.AbilityKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import {extendArray, isNullOrUndefined, MutableState} from '@polyvharmony/media-player-sdk'

export class PLVBackgroundTaskManager {

  private static readonly instance = new PLVBackgroundTaskManager()

  private constructor() {
  }

  static getInstance() {
    return PLVBackgroundTaskManager.instance
  }

  runningBackgroundTaskType: MutableState<backgroundTaskManager.BackgroundMode | null> = new MutableState(null)

  private refContext: common.UIAbilityContext | null = null
  private backgroundTasks: backgroundTaskManager.BackgroundMode[] = []

  setupContext(context: common.UIAbilityContext) {
    this.refContext = context
  }

  async pushBackgroundTask(type: backgroundTaskManager.BackgroundMode) {
    this.backgroundTasks.push(type)
    if (isNullOrUndefined(this.runningBackgroundTaskType.value)) {
      await this.updateCurrentRunningBackgroundTask()
    }
  }

  async removeBackgroundTask(type: backgroundTaskManager.BackgroundMode) {
    extendArray(this.backgroundTasks).remove_ext(type)
    if (this.runningBackgroundTaskType.value === type) {
      await this.updateCurrentRunningBackgroundTask()
    }
  }

  private async updateCurrentRunningBackgroundTask() {
    let currentRunningTask = this.runningBackgroundTaskType.value
    const shouldStopBackgroundTask = !isNullOrUndefined(currentRunningTask) && this.backgroundTasks.find(task => task === currentRunningTask) === undefined
    if (shouldStopBackgroundTask) {
      await this.stopBackgroundTask()
    }

    currentRunningTask = this.runningBackgroundTaskType.value
    const shouldStartBackgroundTask = isNullOrUndefined(currentRunningTask) && this.backgroundTasks.length > 0
    if (shouldStartBackgroundTask) {
      await this.startBackgroundTask(this.backgroundTasks[0])
    }
  }

  private async startBackgroundTask(type: backgroundTaskManager.BackgroundMode) {
    if (this.refContext === null) {
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
    await backgroundTaskManager.startBackgroundRunning(this.refContext, type, wantAgentObject)
    this.runningBackgroundTaskType.setValue(type)
  }

  private async stopBackgroundTask() {
    if (this.refContext === null) {
      return
    }
    await backgroundTaskManager.stopBackgroundRunning(this.refContext)
    this.runningBackgroundTaskType.setValue(null)
  }

  async destroy() {
    this.backgroundTasks = []
    await this.stopBackgroundTask()
    this.refContext = null
  }

}