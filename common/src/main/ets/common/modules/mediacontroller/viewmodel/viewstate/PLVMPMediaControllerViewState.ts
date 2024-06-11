export class PLVMPMediaControllerViewState {
  controllerVisible: boolean = true
  controllerLocking: boolean = false
  progressSliderDragging: boolean = false
  progressSliderDragPosition: number = 0
  progressSliderWaitSeekFinish: boolean = false
  longPressSpeeding: boolean = false
  speedBeforeLongPress: number = 1
  floatActionLayouts: PLVMPMediaControllerFloatAction[] = []
  errorOverlayLayoutVisible: boolean = false
  completeOverlayLayoutVisible: boolean = false

  isFloatActionLayoutVisible(): boolean {
    return this.floatActionLayouts.length > 0
  }

  isMediaStopOverlayVisible(): boolean {
    return this.errorOverlayLayoutVisible || this.completeOverlayLayoutVisible
  }

}

export type PLVMPMediaControllerFloatAction = 'more' | 'bitRate' | 'speed'