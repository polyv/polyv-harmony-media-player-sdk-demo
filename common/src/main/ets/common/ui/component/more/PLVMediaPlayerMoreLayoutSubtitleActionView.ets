import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

@Component
export struct PLVMediaPlayerMoreLayoutSubtitleActionView {
  @Consume dependScope: DependScope
  iconResourceActive: Resource = $r("app.media.plv_media_player_more_subtitle_action_icon_active_port")
  iconResourceInactive: Resource = $r("app.media.plv_media_player_more_subtitle_action_icon_inactive_port")
  textFontColorActive: string = '#CC333333'
  textFontColorInactive: string = '#CC333333'
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controlViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State isCurrentSubtitleEnable: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.isVisible = viewState.supportSubtitles.length > 0
      this.isCurrentSubtitleEnable = viewState.currentSubtitle !== null && viewState.currentSubtitle.length > 0
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      Image(this.isCurrentSubtitleEnable ? this.iconResourceActive : this.iconResourceInactive)
        .width(36)
        .height(36)

      Text($r('app.string.plv_media_player_ui_component_subtitle_setting_text'))
        .margin({
          top: 4
        })
        .fontColor(this.isCurrentSubtitleEnable ? this.textFontColorActive : this.textFontColorInactive)
        .fontSize(12)
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.controlViewModel.popFloatActionLayout()
      this.controlViewModel.pushFloatActionLayout('subtitle')
    })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}