import { MutableObserver, requireNotNull } from '@polyvharmony/media-player-sdk'
import { PLVMarqueeAnimateType } from './model/PLVMarqueeAnimateSettingVO'
import { PLVMarqueeModel, PLVMarqueePlayingState } from './model/PLVMarqueeModel'
import { PLVMarqueeFlicker15PercentView } from './view/PLVMarqueeFlicker15PercentView'
import { PLVMarqueeFlickerDoubleMarqueeView } from './view/PLVMarqueeFlickerDoubleMarqueeView'
import { PLVMarqueeFlickerView } from './view/PLVMarqueeFlickerView'
import { PLVMarqueeRoll15PercentView } from './view/PLVMarqueeRoll15PercentView'
import { PLVMarqueeRollDoubleMarqueeView } from './view/PLVMarqueeRollDoubleMarqueeView'
import { PLVMarqueeRollFlickerView } from './view/PLVMarqueeRollFlickerView'
import { PLVMarqueeRollView } from './view/PLVMarqueeRollView'

@Component
export struct PLVMarqueeView {
  model?: PLVMarqueeModel
  @State isVisible: boolean = true
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    requireNotNull(this.model, () => "model is null")

    this.model?.playingState.observe((playingState) => {
      if (this.model?.animateSetting.isHiddenWhenPause === true) {
        this.isVisible = playingState === PLVMarqueePlayingState.PLAY
      }
    }).pushTo(this.observers)
  }

  build() {
    Stack() {
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.ROLL) {
        PLVMarqueeRollView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.FLICKER) {
        PLVMarqueeFlickerView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.ROLL_FLICKER) {
        PLVMarqueeRollFlickerView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.ROLL_15PERCENT) {
        PLVMarqueeRoll15PercentView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.FLICKER_15PERCENT) {
        PLVMarqueeFlicker15PercentView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.ROLL_DOUBLE_MARQUEE) {
        PLVMarqueeRollDoubleMarqueeView({ model: this.model })
      }
      if (this.model?.animateSetting?.animateType === PLVMarqueeAnimateType.FLICKER_DOUBLE_MARQUEE) {
        PLVMarqueeFlickerDoubleMarqueeView({ model: this.model })
      }
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}