export class PLVMPMediaPlayViewState {
  currentProgress: number = 0
  duration: number = 0
  isPlaying: boolean = false
  isBuffering: boolean = false
  // bytes per second
  bufferingSpeed: number = 0
  speed: number = 1
}