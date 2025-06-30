import { DependScope, extendArray, MutableObserver, PLVMediaSubtitle } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import {
  defineIds,
  parent,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf,
  usePadding
} from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerMoreSubtitleSettingLayoutPort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State isSubtitleEnable: boolean = false
  @State supportSubtitles: PLVMediaSubtitle[][] = []
  @State currentSubtitle: PLVMediaSubtitle[] | null = null
  private lastSelectedSubtitle: PLVMediaSubtitle[] | null = null
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_more_action_layout_close_layout_mask_port',
    'plv_media_player_more_action_layout_container',
    'plv_media_player_more_action_back_iv_port',
    'plv_media_player_more_action_subtitle_action_title',
    'plv_media_player_more_action_show_subtitle_toggle_label',
    'plv_media_player_more_action_show_subtitle_toggle',
    'plv_media_player_more_action_subtitle_container'
  )

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'subtitle'
        && !viewState.isMediaStopOverlayVisible()
    }).pushTo(this.observers)

    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.isSubtitleEnable = viewState.currentSubtitle != null && viewState.currentSubtitle.length > 0
      this.supportSubtitles = viewState.supportSubtitles
      this.currentSubtitle = viewState.currentSubtitle
      if (this.currentSubtitle != null && this.currentSubtitle.length > 0) {
        this.lastSelectedSubtitle = this.currentSubtitle
      }
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.ids.plv_media_player_more_action_layout_close_layout_mask_port)
      .width('100%')
      .height('100%')
      .onClick(() => {
        this.controllerViewModel.popFloatActionLayout()
      })

      RelativeContainer() {

        Image($r("app.media.plv_media_player_back_icon"))
          .id(this.ids.plv_media_player_more_action_back_iv_port)
          .width(20)
          .height(20)
          .fillColor('#CC000000')
          .margin({
            left: 20,
            top: 16
          })
          .alignRules({
            top: toTopOf(parent),
            left: toStartOf(parent)
          })
          .onClick(() => {
            this.controllerViewModel.popFloatActionLayout()
            this.controllerViewModel.pushFloatActionLayout('more')
          })

        Text($r("app.string.plv_media_player_ui_component_subtitle_setting_text"))
          .id(this.ids.plv_media_player_more_action_subtitle_action_title)
          .fontSize(16)
          .fontColor("#CC000000")
          .alignRules({
            top: toTopOf(parent),
            middle: toMiddleOf(parent)
          })
          .margin({
            top: 15
          })

        Text($r("app.string.plv_media_player_ui_component_subtitle_setting_show_switch_label"))
          .id(this.ids.plv_media_player_more_action_show_subtitle_toggle_label)
          .fontSize(14)
          .fontColor("#CC000000")
          .alignRules({
            top: toBottomOf(this.ids.plv_media_player_more_action_back_iv_port),
            left: toStartOf(parent)
          })
          .margin({
            left: 36,
            top: 30
          })

        Toggle({ type: ToggleType.Switch, isOn: this.isSubtitleEnable })
          .id(this.ids.plv_media_player_more_action_show_subtitle_toggle)
          .width(38)
          .height(24)
          .selectedColor('#3F76FC')
          .switchPointColor('#FFFFFF')
          .alignRules({
            center: toCenterOf(this.ids.plv_media_player_more_action_show_subtitle_toggle_label),
            right: toEndOf(parent)
          })
          .margin({
            right: 16
          })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.mediaViewModel.setShowSubtitles(this.lastSelectedSubtitle ?? this.supportSubtitles[0] ?? [])
            } else {
              this.mediaViewModel.setShowSubtitles([])
            }
          })

        Scroll() {
          Column() {
            ForEach(
              this.supportSubtitles,
              (subtitle: PLVMediaSubtitle[]) => {
                Column() {
                  Row() {
                    Text(this.getSubtitleShowText(subtitle))
                      .fontSize(14)
                      .fontColor(this.equals(this.currentSubtitle, subtitle) ? "#3F76FC" : "#CC000000")
                    Blank()
                  }
                  .width('100%')
                  .padding(usePadding({
                    vertical: 16,
                    horizontal: 20
                  }))
                  .backgroundColor(this.equals(this.currentSubtitle, subtitle) ? "#1A3F76FC" : "#FFFFFF")
                  .borderRadius(8)
                  .borderWidth(1)
                  .borderColor(this.equals(this.currentSubtitle, subtitle) ? "#3F76FC" : "#FFFFFF")
                  .onClick(() => {
                    this.mediaViewModel.setShowSubtitles(subtitle)
                  })
                }
                .width('100%')
                .padding(usePadding({
                  vertical: 4,
                  horizontal: 16
                }))

              },
              (subtitle: PLVMediaSubtitle[]) => {
                return subtitle.map((it) => it.name).join()
              }
            )
          }
          .width('100%')
          .height('100%')
          .visibility(this.isSubtitleEnable ? Visibility.Visible : Visibility.None)
        }
        .id(this.ids.plv_media_player_more_action_subtitle_container)
        .width('100%')
        .height(318)
        .scrollBar(BarState.Off)
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_more_action_show_subtitle_toggle_label)
        })
        .margin(usePadding({
          top: 18
        }))

      }
      .id(this.ids.plv_media_player_more_action_layout_container)
      .width('100%')
      .height(422)
      .backgroundColor('#F7F8FA')
      .borderRadius({
        topLeft: 16,
        topRight: 16
      })
      .alignRules({
        bottom: toBottomOf(parent)
      })

    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  private getSubtitleShowText(subtitle: PLVMediaSubtitle[]): string | Resource {
    if (subtitle.length == 0) {
      return ""
    }
    if (subtitle.length == 1) {
      return subtitle[0].name
    }
    return $r("app.string.plv_media_player_ui_component_subtitle_setting_double_subtitle_prefix", subtitle.map(it => it.name)
      .join("/"))
  }

  private equals(subtitle: PLVMediaSubtitle[] | null, other: PLVMediaSubtitle[] | null): boolean {
    if (subtitle == null || other == null) {
      return subtitle == other
    }
    return subtitle.length == other.length && subtitle.map(it => it.name).join() == other.map(it => it.name).join()
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}