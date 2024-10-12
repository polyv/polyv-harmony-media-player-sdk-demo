import {
  IPLVAuxiliaryMediaPlayer,
  LifecycleAwareDependComponent,
  MutableEvent,
  MutableSource,
  MutableState,
  PLVMediaBitRate,
  PLVMediaPlayerAutoContinueEvent,
  PLVMediaPlayerBusinessErrorEnum,
  PLVMediaPlayerOnCompletedEvent,
  PLVMediaPlayerOnInfoEvent,
  PLVMediaPlayerOnPreparedEvent,
  PLVMediaPlayerPlayingState,
  PLVMediaPlayerState,
  PLVMediaResource
} from '@polyvharmony/media-player-sdk'
import {PLVMPMediaInfoViewState} from "../viewmodel/viewstate/PLVMPMediaInfoViewState";
import {PLVMPMediaPlayViewState} from "../viewmodel/viewstate/PLVMPMediaPlayViewState";

export class PLVMPMediaMediator implements LifecycleAwareDependComponent {

  readonly mediaResource = new MutableState<PLVMediaResource>()
  readonly mediaPlayViewState = new MutableState(new PLVMPMediaPlayViewState());
  readonly mediaInfoViewState = new MutableState(new PLVMPMediaInfoViewState());
  readonly networkPoorEvent = new MutableEvent<number>();
  readonly onChangeBitRateEvent = new MutableEvent<PLVMediaBitRate>();
  readonly onPreparedEvent = new MutableEvent<PLVMediaPlayerOnPreparedEvent>();
  readonly onAutoContinueEvent = new MutableEvent<PLVMediaPlayerAutoContinueEvent>();
  readonly onInfoEvent = new MutableEvent<PLVMediaPlayerOnInfoEvent>();
  readonly onCompleteEvent = new MutableEvent<PLVMediaPlayerOnCompletedEvent>();
  readonly playingState = new MutableState(PLVMediaPlayerPlayingState.PAUSED);
  readonly playerState = new MutableState(PLVMediaPlayerState.STATE_IDLE);
  readonly bufferingSpeed = new MutableState<number>(0)
  readonly businessErrorState = new MutableState<PLVMediaPlayerBusinessErrorEnum | null>(null)

  seekTo?: (progress: number) => void
  getSpeed?: () => number
  setSpeed?: (speed: number) => void
  isPlaying?: () => boolean
  getVolume?: () => number
  setVolume?: (volume: number) => void
  bindAuxiliaryPlayer?: (auxiliaryPlayer: IPLVAuxiliaryMediaPlayer) => void
  unbindAuxiliaryPlayer?: (auxiliaryPlayer: IPLVAuxiliaryMediaPlayer) => void

  onDestroy() {
    MutableSource.disposeAll(this)
  }

}