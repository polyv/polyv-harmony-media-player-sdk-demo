import {PLVMPMediaRepo} from '../../model/PLVMPMediaRepo';
import {
  DerivedState,
  isLiteralTrue,
  LifecycleAwareDependComponent,
  MutableObserver,
  PLVMediaOutputMode,
  PLVMediaPlayer,
  PLVMediaPlayerPlayingState,
  PLVMediaPlayerState,
  PLVMediaSubtitle,
  Rect
} from '@polyvharmony/media-player-sdk';
import {PLVMPMediaPlayViewState} from '../viewstate/PLVMPMediaPlayViewState';
import {PLVMPMediaInfoViewState, PLVMPSubtitleTextStyle} from '../viewstate/PLVMPMediaInfoViewState';

export class UpdateMediaStateUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaRepo
  ) {
    this.repo = repo

    new DerivedState(() => {
      const viewState = new PLVMPMediaPlayViewState();
      viewState.currentProgress = this.repo.player.getStateListenerRegistry().progressState.value ?? 0
      viewState.duration = this.repo.player.getStateListenerRegistry().durationState.value ?? 0
      viewState.isPlaying = this.repo.player.getStateListenerRegistry().playingState.value === PLVMediaPlayerPlayingState.PLAYING
      viewState.playerState = this.repo.player.getStateListenerRegistry().playerState.value ?? PLVMediaPlayerState.STATE_IDLE
      viewState.isBuffering = this.repo.player.getStateListenerRegistry().isBuffering.value ?? false
      viewState.bufferingSpeed = this.repo.mediator.bufferingSpeed.value ?? 0
      viewState.speed = this.repo.player.getStateListenerRegistry().speed.value ?? 1
      viewState.subtitleTexts = this.repo.player.getBusinessListenerRegistry().vodCurrentSubTitleTexts.value ?? []
      return viewState;
    }).relayTo(this.repo.mediator.mediaPlayViewState)
      .pushTo(this.observers);

    new DerivedState(() => {
      const viewState = new PLVMPMediaInfoViewState();
      viewState.title = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.title ?? ""
      viewState.videoSize = this.repo.player.getStateListenerRegistry().videoSize.value ?? new Rect()
      viewState.bitRate = this.repo.player.getBusinessListenerRegistry().currentMediaBitRate.value ?? null
      viewState.supportBitRates = this.repo.player.getBusinessListenerRegistry().supportMediaBitRates.value ?? []
      viewState.outputMode = this.repo.player.getBusinessListenerRegistry().currentMediaOutputMode.value ?? PLVMediaOutputMode.AUDIO_VIDEO
      viewState.supportOutputModes = this.repo.player.getBusinessListenerRegistry().supportMediaOutputModes.value ?? []
      viewState.currentSubtitle = this.repo.player.getBusinessListenerRegistry().currentShowSubTitles.value ?? null
      viewState.supportSubtitles = this.getSupportSubtitles(this.repo.player)
      viewState.progressPreviewImage = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.progressImage ?? null
      viewState.progressPreviewImageInterval = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.progressImageInterval?.toSeconds() ?? -1
      viewState.audioModeCoverImage = this.repo.player.getBusinessListenerRegistry().vodVideoJson.value?.first_image ?? null
      viewState.topSubtitleTextStyle = this.getSubtitleTextStyle(this.repo.player, "top")
      viewState.bottomSubtitleTextStyle = this.getSubtitleTextStyle(this.repo.player, "bottom")
      return viewState;
    }).relayTo(this.repo.mediator.mediaInfoViewState)
      .pushTo(this.observers);
  }

  private getSupportSubtitles(player: PLVMediaPlayer): PLVMediaSubtitle[][] {
    const subtitleSetting = player.getBusinessListenerRegistry().supportSubtitleSetting.value
    if (!subtitleSetting || !subtitleSetting.available) {
      return []
    }
    const singleSubtitles = subtitleSetting.availableSubtitles.map((subtitle) => [subtitle])
    if (subtitleSetting.defaultDoubleSubtitles) {
      return [subtitleSetting.defaultDoubleSubtitles, ...singleSubtitles]
    } else {
      return singleSubtitles
    }
  }

  private getSubtitleTextStyle(player: PLVMediaPlayer, position: 'top' | 'bottom'): PLVMPSubtitleTextStyle {
    const result = new PLVMPSubtitleTextStyle()
    const isDoubleSubtitle = (player.getBusinessListenerRegistry().currentShowSubTitles.value?.length ?? 0) >= 2
    const targetSubtitleStyle = player.getBusinessListenerRegistry().vodVideoJson.value?.player?.subtitles
      ?.find((subtitle) => {
        if (!isDoubleSubtitle) {
          return subtitle.style === "single"
        } else {
          return subtitle.style === "double" && subtitle.position === position
        }
      })
    if (targetSubtitleStyle === undefined) {
      return result
    }
    result.fontColor = targetSubtitleStyle.fontColor ?? "#FFFFFF"
    result.isBold = isLiteralTrue(targetSubtitleStyle.fontBold)
    result.isItalic = isLiteralTrue(targetSubtitleStyle.fontItalics)
    result.backgroundColor = targetSubtitleStyle.backgroundColor ?? "#000000"
    return result
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}