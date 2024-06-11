import { DependScope, MutableObserver, PLVMediaOutputMode } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

@Component
export struct PLVMediaPlayerMoreLayoutAudioModeActionView {
  @Consume dependScope: DependScope
  iconResourceActive: Resource = $r("app.media.plv_media_player_more_audio_mode_action_icon_active")
  iconResourceInactive: Resource = $r("app.media.plv_media_player_more_audio_mode_action_icon_inactive_port")
  textFontColorActive: string = '#CC3F76FC'
  textFontColorInactive: string = '#CC333333'
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controlViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State isCurrentAudioOnly: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.isVisible = viewState.supportOutputModes.includes(PLVMediaOutputMode.AUDIO_ONLY)
      this.isCurrentAudioOnly = viewState.outputMode === PLVMediaOutputMode.AUDIO_ONLY
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      Image(this.isCurrentAudioOnly ? this.iconResourceActive : this.iconResourceInactive)
        .width(36)
        .height(36)

      Text($r('app.string.plv_media_player_ui_component_audio_mode_hint_text'))
        .margin({
          top: 4
        })
        .fontColor(this.isCurrentAudioOnly ? this.textFontColorActive : this.textFontColorInactive)
        .fontSize(12)
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.mediaViewModel.changeMediaOutputMode(this.isCurrentAudioOnly ? PLVMediaOutputMode.AUDIO_VIDEO : PLVMediaOutputMode.AUDIO_ONLY)
      this.controlViewModel.popFloatActionLayout()
    })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}