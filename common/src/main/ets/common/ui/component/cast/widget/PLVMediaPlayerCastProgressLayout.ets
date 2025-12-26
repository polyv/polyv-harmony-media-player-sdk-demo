import {
  DependScope, millis, MutableObserver, watchStates
} from '@polyvharmony/media-player-sdk'
import { PLVMPCastViewModel } from '../../../../modules/cast/viewmodel/PLVMPCastViewModel'
import { defineIds, parent, toCenterOf, toEndOf, toStartOf } from '../../../../utils/arkts-no-everything'
import { formatDuration } from '../../../../utils/PLVTimeUtils'

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
export struct PLVMediaPlayerCastProgressLayout {
  @Consume dependScope: DependScope
  private castViewModel = this.dependScope.get(PLVMPCastViewModel)
  private videoProgress: number = 0
  private videoDuration: number = 0
  private dragProgress: number = 0
  @State sliderProgress: number = 0
  @State progressText: string = "00:00"
  @State durationText: string = "00:00"
  @State isDragging: boolean = false
  private readonly ids = defineIds(
    'plv_media_player_cast_progress_slider',
    'plv_media_player_cast_progress_text'
  )
  private observers: MutableObserver[] = []

  aboutToAppear() {
    watchStates(() => {
      this.videoProgress = this.castViewModel.position.value?.toMillis() ?? 0
      this.videoDuration = this.castViewModel.duration.value?.toMillis() ?? 0
      this.durationText = formatDuration(this.videoDuration)
      this.updateSliderProgress()
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Slider({
        value: this.sliderProgress,
        min: 0,
        max: SLIDER_MAX_PROGRESS,
        direction: Axis.Horizontal
      })
        .id(this.ids.plv_media_player_cast_progress_slider)
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
        .alignRules({
          left: toStartOf(parent),
          right: toStartOf(this.ids.plv_media_player_cast_progress_text),
          center: toCenterOf(parent)
        })
        .margin({
          right: 8
        })
        .onChange((value: number, mode: SliderChangeMode) => {
          switch (mode) {
            case SliderChangeMode.Begin:
            case SliderChangeMode.Moving:
              this.isDragging = true
              this.dragProgress = value / SLIDER_MAX_PROGRESS * this.videoDuration
              this.updateSliderProgress()
              break;
            case SliderChangeMode.End:
              this.isDragging = false
              this.dragProgress = value / SLIDER_MAX_PROGRESS * this.videoDuration
              this.castViewModel.seek(millis(this.dragProgress))
              this.videoProgress = this.dragProgress
              break;
            case SliderChangeMode.Click:
              this.dragProgress = value / SLIDER_MAX_PROGRESS * this.videoDuration
              this.castViewModel.seek(millis(this.dragProgress))
              this.videoProgress = this.dragProgress
              break;
          }
        })

      Text() {
        Span(this.progressText)
        Span(" / ")
          .fontSize(12)
        Span(this.durationText)
      }
      .id(this.ids.plv_media_player_cast_progress_text)
      .fontSize(14)
      .fontColor('#FFFFFF')
      .alignRules({
        right: toEndOf(parent),
        center: toCenterOf(parent)
      })
    }
    .width('100%')

  }

  private updateSliderProgress() {
    if (this.videoDuration === 0) {
      return
    }
    if (this.isDragging) {
      this.sliderProgress = this.dragProgress / this.videoDuration * SLIDER_MAX_PROGRESS
      this.progressText = formatDuration(this.dragProgress)
    } else {
      this.sliderProgress = this.videoProgress / this.videoDuration * SLIDER_MAX_PROGRESS
      this.progressText = formatDuration(this.videoProgress)
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}