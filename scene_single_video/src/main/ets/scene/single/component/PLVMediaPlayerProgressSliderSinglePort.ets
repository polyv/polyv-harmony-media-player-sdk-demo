import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { isLandscape, PLVMPMediaControllerViewModel, PLVMPMediaViewModel } from 'media-player-common'

// <editor-fold defaultstate="collapsed" desc="UI样式常量定义">
const SLIDER_MAX_PROGRESS = 10000
const SLIDER_BACKGROUND_COLOR = '#33FFFFFF'
const SLIDER_PROGRESS_COLOR_NORMAL = '#99FFFFFF'
const SLIDER_PROGRESS_COLOR_ON_DRAG = '#CCFFFFFF'
const SLIDER_THUMB_COLOR = '#FFFFFF'
const SLIDER_HEIGHT_NORMAL = 2
const SLIDER_HEIGHT_ON_DRAG = 8
const SLIDER_RADIUS_NORMAL = 4
const SLIDER_RADIUS_ON_DRAG = 8
const THUMB_WIDTH_NORMAL = 4
const THUMB_HEIGHT_NORMAL = 4
const THUMB_RADIUS_NORMAL = 4
const THUMB_WIDTH_ON_DRAG = 8
const THUMB_HEIGHT_ON_DRAG = 14
const THUMB_RADIUS_ON_DRAG = 4

// </editor-fold>

@Component
export struct PLVMediaPlayerProgressSliderSinglePort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private videoProgress: number = 0
  private videoDuration: number = 0
  private dragProgress: number = 0
  private waitDragSeekFinish: boolean = false
  @State sliderProgress: number = 0
  @State isDragging: boolean = false
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear() {
    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.videoProgress = viewState.currentProgress
      this.videoDuration = viewState.duration
      this.updateSliderProgress()
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isDragging = viewState.progressSliderDragging
      this.dragProgress = viewState.progressSliderDragPosition
      this.waitDragSeekFinish = viewState.progressSliderWaitSeekFinish
      this.updateSliderProgress()
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Slider({
      value: this.sliderProgress,
      min: 0,
      max: SLIDER_MAX_PROGRESS,
      direction: Axis.Horizontal
    })
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .trackColor(SLIDER_BACKGROUND_COLOR)
      .trackThickness(this.isDragging ? SLIDER_HEIGHT_ON_DRAG : SLIDER_HEIGHT_NORMAL)
      .trackBorderRadius(this.isDragging ? SLIDER_RADIUS_ON_DRAG : SLIDER_RADIUS_NORMAL)
      .selectedColor(this.isDragging ? SLIDER_PROGRESS_COLOR_ON_DRAG : SLIDER_PROGRESS_COLOR_NORMAL)
      .blockStyle({
        type: SliderBlockType.SHAPE,
        shape: new Rect()
          .width(this.isDragging ? THUMB_WIDTH_ON_DRAG : THUMB_WIDTH_NORMAL)
          .height(this.isDragging ? THUMB_HEIGHT_ON_DRAG : THUMB_HEIGHT_NORMAL)
          .radius(this.isDragging ? THUMB_RADIUS_ON_DRAG : THUMB_RADIUS_NORMAL)
      })
      .blockSize({
        width: this.isDragging ? THUMB_WIDTH_ON_DRAG : THUMB_WIDTH_NORMAL,
        height: this.isDragging ? THUMB_HEIGHT_ON_DRAG : THUMB_HEIGHT_NORMAL
      })
      .blockColor(SLIDER_THUMB_COLOR)
      .onChange((value: number, mode: SliderChangeMode) => {
        switch (mode) {
          case SliderChangeMode.Begin:
            this.controllerViewModel.handleDragSlider('slide', value / SLIDER_MAX_PROGRESS * this.videoDuration)
            break;
          case SliderChangeMode.Moving:
            this.controllerViewModel.handleDragSlider('slide', value / SLIDER_MAX_PROGRESS * this.videoDuration)
            break;
          case SliderChangeMode.End:
            this.controllerViewModel.handleDragSlider('slideFinish', value / SLIDER_MAX_PROGRESS * this.videoDuration)
            break;
          case SliderChangeMode.Click:
            this.controllerViewModel.handleDragSlider('click', value / SLIDER_MAX_PROGRESS * this.videoDuration)
            break;
        }
      })
  }

  private updateSliderProgress() {
    if (this.videoDuration === 0) {
      return
    }
    if (!this.isDragging && this.waitDragSeekFinish) {
      return
    }
    if (this.isDragging) {
      this.sliderProgress = this.dragProgress / this.videoDuration * SLIDER_MAX_PROGRESS
      return
    }
    this.sliderProgress = this.videoProgress / this.videoDuration * SLIDER_MAX_PROGRESS
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}