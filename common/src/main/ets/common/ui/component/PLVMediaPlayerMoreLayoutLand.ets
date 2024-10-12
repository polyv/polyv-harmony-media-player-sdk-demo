import { DependScope, extendArray, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { createId, parent, toEndOf, toStartOf, toTopOf } from '../../utils/arkts-no-everything'
import { PLVMediaPlayerMoreLayoutAudioModeActionView } from './PLVMediaPlayerMoreLayoutAudioModeActionView'
import { PLVMediaPlayerMoreLayoutDownloadActionView } from './PLVMediaPlayerMoreLayoutDownloadActionView'
import { PLVMediaPlayerMoreLayoutSubtitleActionView } from './PLVMediaPlayerMoreLayoutSubtitleActionView'

@Component
export struct PLVMediaPlayerMoreLayoutLand {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_more_action_start_guide_line: string = createId()
  private readonly plv_media_player_more_action_layout_close_layout_mask: string = createId()
  private readonly plv_media_player_more_action_audio_mode_action_view: string = createId()
  private readonly plv_media_player_more_action_subtitle_action_view: string = createId()
  private readonly plv_media_player_more_action_download_action_view: string = createId()
  private readonly plv_media_player_more_action_close_iv: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'more'
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.plv_media_player_more_action_layout_close_layout_mask)
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 90,
        colors: [['#00000000', 0], ['#cc000000', 0.5], ['#cc000000', 1]]
      })
      .responseRegion({
        width: '50%'
      })
      .onClick(() => {
        this.controllerViewModel.popFloatActionLayout()
      })

      Shape() {
      }
      .id(this.plv_media_player_more_action_start_guide_line)
      .width('56%')
      .height('100%')
      .alignRules({
        left: toStartOf(parent)
      })
      .hitTestBehavior(HitTestMode.None)

      PLVMediaPlayerMoreLayoutAudioModeActionView({
        iconResourceInactive: $r('app.media.plv_media_player_more_audio_mode_action_icon_inactive_land'),
        textFontColorInactive: '#CCFFFFFF'
      })
        .id(this.plv_media_player_more_action_audio_mode_action_view)
        .alignRules({
          left: toEndOf(this.plv_media_player_more_action_start_guide_line),
          top: toTopOf(parent)
        })
        .margin({
          top: 48
        })

      PLVMediaPlayerMoreLayoutSubtitleActionView({
        iconResourceActive: $r('app.media.plv_media_player_more_subtitle_action_icon_active_land'),
        iconResourceInactive: $r('app.media.plv_media_player_more_subtitle_action_icon_inactive_land'),
        textFontColorActive: '#CCFFFFFF',
        textFontColorInactive: '#CCFFFFFF'
      })
        .id(this.plv_media_player_more_action_subtitle_action_view)
        .alignRules({
          left: toEndOf(this.plv_media_player_more_action_audio_mode_action_view),
          top: toTopOf(parent)
        })
        .margin({
          top: 48,
          left: 28
        })

      PLVMediaPlayerMoreLayoutDownloadActionView({
        iconResource: $r("app.media.plv_media_player_more_download_action_icon_land"),
        textFontColor: "#CCFFFFFF"
      })
        .id(this.plv_media_player_more_action_download_action_view)
        .alignRules({
          left: toEndOf(this.plv_media_player_more_action_subtitle_action_view),
          top: toTopOf(parent)
        })
        .margin({
          top: 48,
          left: 28
        })

      Image($r('app.media.plv_media_player_float_menu_close_icon'))
        .id(this.plv_media_player_more_action_close_iv)
        .width(48)
        .height(48)
        .padding(12)
        .margin({
          top: 8,
          right: 8
        })
        .alignRules({
          top: toTopOf(parent),
          right: toEndOf(parent)
        })
        .fillColor('#99FFFFFF')
        .onClick(() => {
          this.controllerViewModel.popFloatActionLayout()
        })

    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}