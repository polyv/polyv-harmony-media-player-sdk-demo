import { DependScope, extendArray, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { defineIds, parent, toEndOf, toStartOf, toTopOf } from '../../../utils/arkts-no-everything'
import { PLVMediaPlayerMoreLayoutAudioModeActionView } from './PLVMediaPlayerMoreLayoutAudioModeActionView'
import { PLVMediaPlayerMoreLayoutDownloadActionView } from './PLVMediaPlayerMoreLayoutDownloadActionView'
import { PLVMediaPlayerMoreLayoutSubtitleActionView } from './PLVMediaPlayerMoreLayoutSubtitleActionView'
import { LengthUnit } from '@kit.ArkUI'
import { PLVMediaPlayerMoreLayoutCastActionView } from './PLVMediaPlayerMoreLayoutCastActionView'

@Component
export struct PLVMediaPlayerMoreLayoutLand {
  @Consume dependScope: DependScope
  showCastAction: boolean = false
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_more_action_start_guide_line',
    'plv_media_player_more_action_layout_close_layout_mask',
    'plv_media_player_more_action_container',
    'plv_media_player_more_action_close_iv'
  )

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'more'
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.ids.plv_media_player_more_action_layout_close_layout_mask)
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
      .id(this.ids.plv_media_player_more_action_start_guide_line)
      .width('56%')
      .height('100%')
      .alignRules({
        left: toStartOf(parent)
      })
      .hitTestBehavior(HitTestMode.None)

      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center,
        space: {
          main: {
            value: 28,
            unit: LengthUnit.VP
          }
        }
      }) {
        PLVMediaPlayerMoreLayoutAudioModeActionView({
          iconResourceInactive: $r('app.media.plv_media_player_more_audio_mode_action_icon_inactive_land'),
          textFontColorInactive: '#CCFFFFFF'
        })

        PLVMediaPlayerMoreLayoutSubtitleActionView({
          iconResourceActive: $r('app.media.plv_media_player_more_subtitle_action_icon_active_land'),
          iconResourceInactive: $r('app.media.plv_media_player_more_subtitle_action_icon_inactive_land'),
          textFontColorActive: '#CCFFFFFF',
          textFontColorInactive: '#CCFFFFFF'
        })

        if (this.showCastAction) {
          PLVMediaPlayerMoreLayoutCastActionView({
            iconColor: '#FFFFFF',
            textFontColor: '#CCFFFFFF'
          })
        }

        PLVMediaPlayerMoreLayoutDownloadActionView({
          iconResource: $r("app.media.plv_media_player_more_download_action_icon_land"),
          textFontColor: "#CCFFFFFF"
        })
      }
      .id(this.ids.plv_media_player_more_action_container)
      .height('100%')
      .alignRules({
        left: toEndOf(this.ids.plv_media_player_more_action_start_guide_line),
        right: toEndOf(parent)
      })
      .padding({
        top: 48,
        right: 60
      })

      Image($r('app.media.plv_media_player_float_menu_close_icon'))
        .id(this.ids.plv_media_player_more_action_close_iv)
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