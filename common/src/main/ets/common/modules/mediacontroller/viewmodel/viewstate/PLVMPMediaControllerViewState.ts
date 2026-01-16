export class PLVMPMediaControllerViewState {
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

export type PLVMPMediaControllerFloatAction = 'more' | 'bitRate' | 'speed' | 'subtitle' | 'knowledge'

export type PLVMPVideoViewLocation = {
  width: number,
  height: number,
  offset: {
    x: number,
    y: number
  }
}