import { PLVMarqueeModel } from '../model/PLVMarqueeModel'
import { PLVMarqueeDoubleMarqueeSubTextView } from './PLVMarqueeDoubleMarqueeSubTextView'
import { PLVMarqueeFlickerView } from './PLVMarqueeFlickerView'

@Component
export struct PLVMarqueeFlickerDoubleMarqueeView {
  model?: PLVMarqueeModel

  build() {
    Stack() {
      PLVMarqueeFlickerView({
        model: this.model
      })
      PLVMarqueeDoubleMarqueeSubTextView({
        model: this.model
      })
    }
  }
}