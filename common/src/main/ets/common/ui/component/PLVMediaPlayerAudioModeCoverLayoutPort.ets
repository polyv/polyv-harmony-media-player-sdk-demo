import { DependScope, MutableObserver, PLVMediaOutputMode, seconds } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { createId, parent, toCenterOf, toMiddleOf, usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerAudioModeCoverLayoutPort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State isVisible: boolean = false
  @State audioImageRotation: number = 0
  @State audioModeCoverImage: string | null = null
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_audio_mode_cover_layout_background: string = createId()
  private readonly plv_media_player_audio_mode_cover_layout_content: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.isVisible = viewState.outputMode === PLVMediaOutputMode.AUDIO_ONLY
      this.audioModeCoverImage = viewState.audioModeCoverImage
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Stack() {
        Rect()
          .width('100%')
          .height('100%')
          .fill('#041938')
        Shape()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [['#333F76FC', 0], ['#1A3F76FC', 1]]
          })
      }
      .id(this.plv_media_player_audio_mode_cover_layout_background)

      Row() {
        Stack() {
          Image($r('app.media.plv_media_player_audio_mode_image_wrap_bg'))
            .width(88)
            .height(88)

          Image(this.audioModeCoverImage ?? $r('app.media.plv_media_player_audio_mode_cover_placeholder'))
            .width(52)
            .height(52)
            .clipShape(new Circle().width(52).height(52))
            .rotate({
              angle: this.audioImageRotation
            })
            .animation({
              duration: seconds(30).toMillis(),
              curve: Curve.Linear,
              iterations: -1
            })
            .onAppear(() => {
              this.audioImageRotation = 360
            })
        }

        Column() {
          Text($r('app.string.plv_media_player_ui_component_audio_mode_hint_desc_text'))
            .fontColor('#FFFFFF')
            .fontSize(12)
          Image($r('app.media.plv_media_player_audio_mode_audio_volume_visualize_port'))
            .width(178)
            .height(14)
          Row() {
            Image($r('app.media.plv_media_player_audio_mode_switch_video_icon'))
              .width(11)
              .height(11)
            Text($r('app.string.plv_media_player_ui_component_switch_video_hint_text'))
              .fontColor('#FFFFFF')
              .fontSize(12)
              .margin({
                left: 4
              })
          }
          .padding(usePadding({
            horizontal: 14,
            vertical: 4
          }))
          .backgroundColor('#4D000000')
          .borderRadius(20)
          .onClick(() => {
            this.mediaViewModel.changeMediaOutputMode(PLVMediaOutputMode.AUDIO_VIDEO)
          })

        }
        .height(88)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({
          left: 20
        })
      }
      .id(this.plv_media_player_audio_mode_cover_layout_content)
      .alignRules({
        center: toCenterOf(parent),
        middle: toMiddleOf(parent)
      })
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}