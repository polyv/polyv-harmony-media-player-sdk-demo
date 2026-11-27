import { DependScope, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { PLVMPAuxiliaryViewModel } from '../../modules/auxiliary/viewmodel/PLVMPAuxiliaryViewModel'
import { PLVMPCastViewModel } from '../../modules/cast/viewmodel/PLVMPCastViewModel'

/** 单视频、Feed 共用中央控制。只占按钮区域，不拦截其余画面。 */
@Component
export struct PLVMediaPlayerStepSeekLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private auxiliaryViewModel: PLVMPAuxiliaryViewModel = this.dependScope.get(PLVMPAuxiliaryViewModel)
  private castViewModel: PLVMPCastViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isVisible: boolean = false
  @State private isPlaying: boolean = false
  @State private stepSeconds: number = 15
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(() => {
      const state = this.controllerViewModel.mediaControllerViewState.value
      const advert = this.auxiliaryViewModel.auxiliaryInfoViewState.value
      this.stepSeconds = state?.seekStepSeconds ?? 15
      this.isPlaying = this.mediaViewModel.mediaPlayViewState.value?.isPlaying ?? false
      // 完成态同样显示；不依赖后台开关，也不按播放器准备状态或时长隐藏。
      this.isVisible = (state?.seekButtonsEnabled ?? false)
        && (state?.controllerVisible ?? false)
        && !(state?.controllerLocking ?? false)
        && !(state?.errorOverlayLayoutVisible ?? false)
        && !(state?.isFloatActionLayoutVisible() ?? false)
        && !(state?.progressSliderDragging ?? false)
        && !(state?.longPressSpeeding ?? false)
        && !(this.castViewModel.isCasting.value ?? false)
        && !(advert?.stage.isAuxiliaryStage() ?? false)
    }).pushTo(this.observers)
  }

  @Builder
  private seekButton(forward: boolean) {
    Stack() {
      Image(forward ? $r('app.media.plv_media_player_seek_forward') : $r('app.media.plv_media_player_seek_backward'))
        .width(40)
        .height(40)
        .hitTestBehavior(HitTestMode.None)
      Text(`${this.stepSeconds}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .hitTestBehavior(HitTestMode.None)
    }
    .width(56)
    .height(56)
    .hitTestBehavior(HitTestMode.Block)
    .accessibilityText(forward ? $r('app.string.plv_media_player_step_forward', this.stepSeconds)
      : $r('app.string.plv_media_player_step_backward', this.stepSeconds))
    .onClick(() => this.controllerViewModel.seekByStep(forward))
  }

  build() {
    if (this.isVisible) {
      Row({ space: 20 }) {
        this.seekButton(false)
        Stack() {
          Image(this.isPlaying ? $r('app.media.plv_media_player_play_button_icon_to_pause')
            : $r('app.media.plv_media_player_play_button_icon_to_play'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain)
            .hitTestBehavior(HitTestMode.None)
        }
        .width(56)
        .height(56)
        // 点击绑在此 Stack 自身，Block 不会挡住内部的点击处理。
        .hitTestBehavior(HitTestMode.Block)
        .accessibilityText(this.isPlaying ? $r('app.string.plv_media_player_step_pause')
          : $r('app.string.plv_media_player_step_play'))
        .onClick(() => {
          if (this.isPlaying) this.mediaViewModel.pause()
          else this.mediaViewModel.start()
        })
        this.seekButton(true)
      }
      .width(208)
      .height(56)
      .hitTestBehavior(HitTestMode.Default)
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
