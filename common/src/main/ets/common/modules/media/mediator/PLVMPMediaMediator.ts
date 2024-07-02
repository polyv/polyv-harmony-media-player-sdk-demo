import {
  IPLVAuxiliaryMediaPlayer,
  MutableEvent,
  MutableState,
  PLVMediaPlayerBusinessErrorEnum,
  PLVMediaPlayerOnInfoEvent,
  PLVMediaPlayerPlayingState,
  PLVMediaPlayerState
} from '@polyvharmony/media-player-sdk'
import {PLVMPMediaInfoViewState} from "../viewmodel/viewstate/PLVMPMediaInfoViewState";

export class PLVMPMediaMediator {

  seekTo?: (progress: number) => void
  onInfoEvent?: MutableEvent<PLVMediaPlayerOnInfoEvent>
  getSpeed?: () => number
  setSpeed?: (speed: number) => void
  isPlaying?: () => boolean
  getVolume?: () => number
  setVolume?: (volume: number) => void
  businessErrorState?: MutableState<PLVMediaPlayerBusinessErrorEnum | null>
  playingState?: MutableState<PLVMediaPlayerPlayingState>
  playerState?: MutableState<PLVMediaPlayerState>
  mediaInfo?: () => PLVMPMediaInfoViewState | undefined
  bindAuxiliaryPlayer?: (auxiliaryPlayer: IPLVAuxiliaryMediaPlayer) => void
  unbindAuxiliaryPlayer?: (auxiliaryPlayer: IPLVAuxiliaryMediaPlayer) => void

}