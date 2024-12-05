import { DependScope, extendArray, MutableObserver, PLVMediaSubtitle } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import {
  createId,
  parent,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toStartOf,
  toTopOf,
  usePadding
} from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerMoreSubtitleSettingLayoutLand {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State isSubtitleEnable: boolean = false
  @State supportSubtitles: PLVMediaSubtitle[][] = []
  @State currentSubtitle: PLVMediaSubtitle[] | null = null
  private lastSelectedSubtitle: PLVMediaSubtitle[] | null = null
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_more_action_start_guide_line: string = createId()
  private readonly plv_media_player_more_action_layout_close_layout_mask: string = createId()
  private readonly plv_media_player_more_action_close_iv: string = createId()
  private readonly plv_media_player_more_action_show_subtitle_toggle_label: string = createId()
  private readonly plv_media_player_more_action_show_subtitle_toggle: string = createId()
  private readonly plv_media_player_more_action_subtitle_container: string = createId()

  // </editor-fold>

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
      .width('60%')
      .height('100%')
      .alignRules({
        left: toStartOf(parent)
      })
      .hitTestBehavior(HitTestMode.None)

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

      Text($r("app.string.plv_media_player_ui_component_subtitle_setting_show_switch_label"))
        .id(this.plv_media_player_more_action_show_subtitle_toggle_label)
        .fontSize(14)
        .fontColor("#FFFFFF")
        .alignRules({
          top: toTopOf(parent),
          left: toEndOf(this.plv_media_player_more_action_start_guide_line)
        })
        .margin({
          top: 74
        })

      Toggle({ type: ToggleType.Switch, isOn: this.isSubtitleEnable })
        .id(this.plv_media_player_more_action_show_subtitle_toggle)
        .width(38)
        .height(24)
        .selectedColor('#3F76FC')
        .switchPointColor('#FFFFFF')
        .alignRules({
          center: toCenterOf(this.plv_media_player_more_action_show_subtitle_toggle_label),
          left: toEndOf(this.plv_media_player_more_action_show_subtitle_toggle_label)
        })
        .margin({
          left: 20
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
                    .fontColor(this.equals(this.currentSubtitle, subtitle) ? "#3F76FC" : "#FFFFFF")
                  Blank()
                }
                .width('100%')
                .padding(usePadding({
                  vertical: 12
                }))
                .onClick(() => {
                  this.mediaViewModel.setShowSubtitles(subtitle)
                })
              }
              .width('100%')
              .padding(usePadding({
                vertical: 12
              }))

            },
            (subtitle: PLVMediaSubtitle[]) => {
              return subtitle.map((it) => it.name).join()
            }
          )
        }
        .visibility(this.isSubtitleEnable ? Visibility.Visible : Visibility.None)
      }
      .id(this.plv_media_player_more_action_subtitle_container)
      .width('40%')
      .height(240)
      .scrollBar(BarState.Off)
      .alignRules({
        top: toBottomOf(this.plv_media_player_more_action_show_subtitle_toggle_label),
        left: toStartOf(this.plv_media_player_more_action_show_subtitle_toggle_label)
      })
      .margin(usePadding({
        top: 24
      }))

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