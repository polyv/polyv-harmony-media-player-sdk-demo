import { PLVMPMediaConfig } from '../../../media/config/PLVMPMediaConfig'

export class PLVMPMediaControllerViewState {
  seekButtonsEnabled: boolean = PLVMPMediaConfig.seekButtonsEnabled
  seekStepSeconds: number = PLVMPMediaConfig.seekStepSeconds
  // 仅供连续点击累加和提交使用，不覆盖 UI 的真实播放进度。
  stepSeekPosition?: number = undefined
  controllerVisible: boolean = false
  controllerLocking: boolean = false
  progressSliderDragging: boolean = false
  progressSliderDragPosition: number = 0
  progressSliderWaitSeekFinish: boolean = false
  longPressSpeeding: boolean = false
  speedBeforeLongPress: number = 1
  floatActionLayouts: PLVMPMediaControllerFloatAction[] = []
  videoViewLocation: PLVMPVideoViewLocation = {width: 0, height: 0, offset: {x: 0, y: 0}}
  errorOverlayLayoutVisible: boolean = false
  completeOverlayLayoutVisible: boolean = false

  isFloatActionLayoutVisible(): boolean {
    return this.floatActionLayouts.length > 0
  }

  isMediaStopOverlayVisible(): boolean {
    return this.errorOverlayLayoutVisible || this.completeOverlayLayoutVisible
  }

}

export type PLVMPMediaControllerFloatAction = 'more' | 'bitRate' | 'speed' | 'route' | 'subtitle' | 'knowledge'

export type PLVMPVideoViewLocation = {
  width: number,
  height: number,
  offset: {
    x: number,
    y: number
  }
}
