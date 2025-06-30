import { DependScope, extendArray, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { defineIds, parent, toCenterOf, toEndOf, toTopOf, usePadding } from '../../utils/arkts-no-everything'

@Component
export struct PLVMediaPlayerSpeedSelectLayoutLand {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentSpeed: number = 1
  private supportSpeeds: number[] = [0.5, 1.0, 1.5, 2.0]
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

      Column() {
        ForEach(this.supportSpeeds, (speed: number) => {
          Text(`${speed.toFixed(1)}x`)
            .fontSize(14)
            .fontColor(this.currentSpeed === speed ? '#3F76FC' : '#FFFFFF')
            .margin(usePadding({
              vertical: 24
            }))
            .onClick(() => {
              this.mediaViewModel.setSpeed(speed)
              this.controllerViewModel.popFloatActionLayout()
            })
        }, (speed: number) => speed.toString())
      }
      .id(this.ids.plv_media_player_speed_select_content)
      .alignRules({
        center: toCenterOf(parent),
        right: toEndOf(parent)
      })
      .margin({
        right: 167
      })

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