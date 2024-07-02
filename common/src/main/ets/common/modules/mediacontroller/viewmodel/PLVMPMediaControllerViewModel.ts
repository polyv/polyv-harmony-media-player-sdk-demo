import {
  extendNumber,
  LifecycleAwareDependComponent,
  MutableEvent,
  MutableObserver,
  MutableState,
  PLVMediaPlayerOnInfoEvent,
  safe
} from '@polyvharmony/media-player-sdk';
import {
  PLVMPMediaControllerFloatAction,
  PLVMPMediaControllerViewState,
  PLVMPVideoViewLocation
} from './viewstate/PLVMPMediaControllerViewState';
import {PLVBrightnessManager} from "../../../utils/PLVBrightnessManager";
import {PLVMPMediaControllerUseCases} from "./usecase/PLVMPMediaControllerUseCases";
import {PLVMPMediaControllerRepo} from "../model/PLVMPMediaControllerRepo";

export class PLVMPMediaControllerViewModel implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaControllerRepo
  private readonly useCases: PLVMPMediaControllerUseCases

  readonly mediaControllerViewState = new MutableState<PLVMPMediaControllerViewState>(new PLVMPMediaControllerViewState())
  // 亮度更新事件，范围 0.0 ~ 1.0
  readonly brightnessUpdateEvent = new MutableEvent<number>()
  // 音量更新事件，范围 0 ~ 100
  readonly volumeUpdateEvent = new MutableEvent<number>()

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPMediaControllerRepo,
    useCases: PLVMPMediaControllerUseCases
  ) {
    this.repo = repo
    this.useCases = useCases

    this.observeSeekFinishEvent()
    this.observeMediaStopState()
  }

  handleDragSlider(event: 'slide' | 'slideFinish' | 'click', progress: number) {
    switch (event) {
      case "slide":
        this.mediaControllerViewState.mutate({
          progressSliderDragging: true,
          progressSliderWaitSeekFinish: true,
          progressSliderDragPosition: progress
        })
        break;
      case "slideFinish":
        if (this.mediaControllerViewState.value?.progressSliderDragging) {
          this.repo.mediaMediator.seekTo?.apply(null, [this.mediaControllerViewState.value?.progressSliderDragPosition ?? 0])
        }
        this.mediaControllerViewState.mutate({
          progressSliderDragging: false,
          progressSliderDragPosition: 0
        })
        break;
      case "click":
        this.repo.mediaMediator.seekTo?.apply(null, [progress])
        this.mediaControllerViewState.mutate({
          progressSliderWaitSeekFinish: true
        })
        break;
    }
  }

  handleDragGestureSeek(event: 'update' | 'end', progress: number) {
    switch (event) {
      case "update":
        this.handleDragSlider('slide', progress)
        break;
      case "end":
        this.handleDragSlider('slideFinish', progress)
        break;
    }
  }

  changeControllerVisible(toVisible?: boolean) {
    const currentVisible = this.mediaControllerViewState.value?.controllerVisible ?? false
    this.mediaControllerViewState.mutate({
      controllerVisible: toVisible ?? !currentVisible
    })
  }

  handleLongPressSpeeding(event: 'start' | 'end') {
    switch (event) {
      case "start":
        if (!this.repo.mediaMediator.isPlaying?.apply(null)) {
          break;
        }
        this.mediaControllerViewState.mutate({
          longPressSpeeding: true,
          speedBeforeLongPress: this.repo.mediaMediator.getSpeed?.apply(null)
        })
        this.repo.mediaMediator.setSpeed?.apply(null, [2])
        break;
      case "end":
        if (!this.mediaControllerViewState.value?.longPressSpeeding) {
          break;
        }
        this.repo.mediaMediator.setSpeed?.apply(null, [this.mediaControllerViewState.value?.speedBeforeLongPress ?? 1])
        this.mediaControllerViewState.mutate({
          longPressSpeeding: false,
          speedBeforeLongPress: 1
        })
        break;
    }
  }

  async changeBrightness(direction: 'up' | 'down') {
    const currentBrightnessResult = await safe(PLVBrightnessManager.getInstance().getBrightness())
    if (!currentBrightnessResult.success || currentBrightnessResult.data === undefined) {
      return
    }
    const currentBrightness = currentBrightnessResult.data < 0 ? 0.5 : currentBrightnessResult.data
    let nextBrightness = direction === 'up' ? currentBrightness + 0.1 : currentBrightness - 0.1
    nextBrightness = extendNumber(nextBrightness).coerceIn_ext(0, 1)
    const updateResult = await safe(PLVBrightnessManager.getInstance().setBrightness(nextBrightness))
    if (updateResult.success) {
      this.brightnessUpdateEvent.value = nextBrightness
    }
  }

  changeVolume(direction: 'up' | 'down') {
    const currentVolume = this.repo.mediaMediator.getVolume?.apply(null)
    if (currentVolume === undefined) {
      return
    }
    let nextVolume = direction === 'up' ? currentVolume + 10 : currentVolume - 10
    nextVolume = extendNumber(nextVolume).coerceIn_ext(0, 100)
    this.repo.mediaMediator.setVolume?.apply(null, [nextVolume])
    this.volumeUpdateEvent.value = nextVolume
  }

  lockMediaController(action: 'lock' | 'unlock') {
    switch (action) {
      case "lock":
        this.mediaControllerViewState.mutate({
          controllerLocking: true
        })
        break;
      case "unlock":
        this.mediaControllerViewState.mutate({
          controllerLocking: false
        })
        break;
    }
  }

  pushFloatActionLayout(layout: PLVMPMediaControllerFloatAction) {
    this.mediaControllerViewState.mutate({
      floatActionLayouts: [...this.mediaControllerViewState.value?.floatActionLayouts ?? [], layout]
    })
  }

  popFloatActionLayout() {
    const floatActionLayouts = this.mediaControllerViewState.value?.floatActionLayouts ?? []
    if (floatActionLayouts.length === 0) {
      return
    }
    floatActionLayouts.pop()
    this.mediaControllerViewState.mutate({
      floatActionLayouts: floatActionLayouts
    })
  }

  updateVideoViewLocation(videoViewLocation: PLVMPVideoViewLocation) {
    this.mediaControllerViewState.mutate({
      videoViewLocation: videoViewLocation
    })
  }

  private observeSeekFinishEvent() {
    this.repo.mediaMediator.onInfoEvent?.observe((onInfo) => {
      if (this.mediaControllerViewState.value?.progressSliderWaitSeekFinish
        && [PLVMediaPlayerOnInfoEvent.MEDIA_INFO_AUDIO_SEEK_RENDERING_START,
          PLVMediaPlayerOnInfoEvent.MEDIA_INFO_VIDEO_SEEK_RENDERING_START,
          PLVMediaPlayerOnInfoEvent.MEDIA_INFO_AUDIO_RENDERING_START,
          PLVMediaPlayerOnInfoEvent.MEDIA_INFO_VIDEO_RENDERING_START
        ].includes(onInfo.what)) {
        this.mediaControllerViewState.mutate({
          progressSliderWaitSeekFinish: false
        })
      }
    }).pushTo(this.observers)
  }

  private observeMediaStopState() {
    this.useCases.updateMediaStopOverlayUseCase.businessErrorState.observe((error) => {
      this.mediaControllerViewState.mutate({
        errorOverlayLayoutVisible: error !== null
      })
    }).pushTo(this.observers)

    this.useCases.updateMediaStopOverlayUseCase.playCompleteState.observe((complete) => {
      this.mediaControllerViewState.mutate({
        completeOverlayLayoutVisible: complete
      })
    }).pushTo(this.observers)
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}