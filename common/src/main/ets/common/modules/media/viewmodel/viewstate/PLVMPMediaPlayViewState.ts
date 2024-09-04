import {PLVMediaPlayerState, PLVVodSubtitleText} from '@polyvharmony/media-player-sdk';

export class PLVMPMediaPlayViewState {
  currentProgress: number = 0
  duration: number = 0
  isPlaying: boolean = false
  playerState: PLVMediaPlayerState = PLVMediaPlayerState.STATE_IDLE
  isBuffering: boolean = false
  // bytes per second
  bufferingSpeed: number = 0
  speed: number = 1
  subtitleTexts: PLVVodSubtitleText[] = []
}