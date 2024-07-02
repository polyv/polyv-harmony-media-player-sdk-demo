import { DependScope, MutableObserver, PLVMediaPlayStage } from '@polyvharmony/media-player-sdk'
import { PLVMPAuxiliaryViewModel } from '../../modules/auxiliary/viewmodel/PLVMPAuxiliaryViewModel'

@Component
export struct PLVMediaPlayerAuxiliaryCountDownTextView {
  @Consume dependScope: DependScope
  private auxiliaryViewModel: PLVMPAuxiliaryViewModel = this.dependScope.get(PLVMPAuxiliaryViewModel)
  @State isVisible: boolean = false
  @State timeLeftInSeconds: number = 0
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.auxiliaryViewModel.auxiliaryPlayViewState.observe((viewState) => {
      this.timeLeftInSeconds = viewState.timeLeftInSeconds
    }).pushTo(this.observers)

    this.auxiliaryViewModel.auxiliaryInfoViewState.observe((viewState) => {
      this.timeLeftInSeconds = viewState?.showDuration.toSeconds() ?? 0
      this.isVisible = viewState !== null
        && [PLVMediaPlayStage.HEAD_ADVERT, PLVMediaPlayStage.TAIL_ADVERT].includes(viewState.stage)
    }).pushTo(this.observers)
  }

  build() {
    Text($r('app.string.plv_media_player_ui_component_auxiliary_time_left_text', this.timeLeftInSeconds.toString()))
      .fontSize(14)
      .fontColor('#FFFFFF')
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}