import { DependScope, extendArray, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { defineIds, parent, toBottomOf, toEndOf, toTopOf, usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerSpeedSelectLayoutLand {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentSpeed: number = 1
  private supportSpeeds: string[] = ["0.5", "0.75", "1", "1.25", "1.5", "2", "3"]
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_speed_select_layout_close_layout_mask_land',
    'plv_media_player_speed_select_content',
    'plv_media_player_speed_select_close_iv_land'
  )

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'speed'
    }).pushTo(this.observers)

    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.currentSpeed = viewState.speed
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Column() {
      }
      .id(this.ids.plv_media_player_speed_select_layout_close_layout_mask_land)
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

      Scroll() {
        Column() {
          ForEach(this.supportSpeeds, (speed: string) => {
            Text(`${speed}x`)
              .fontSize(14)
              .fontColor(this.currentSpeed === parseFloat(speed) ? '#3F76FC' : '#FFFFFF')
              .margin(usePadding({
                vertical: 24
              }))
              .onClick(() => {
                this.mediaViewModel.setSpeed(parseFloat(speed))
                this.controllerViewModel.popFloatActionLayout()
              })
          }, (speed: number) => speed.toString())
        }
        .width(80)
      }
      .id(this.ids.plv_media_player_speed_select_content)
      .scrollable(ScrollDirection.Vertical)
      .alignRules({
        top: toTopOf(parent),
        bottom: toBottomOf(parent),
        right: toEndOf(parent)
      })
      .margin(usePadding({
        vertical: 64,
        right: 87
      }))

      Image($r('app.media.plv_media_player_float_menu_close_icon'))
        .id(this.ids.plv_media_player_speed_select_close_iv_land)
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