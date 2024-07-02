import { PLVMarqueeModel } from '../model/PLVMarqueeModel'
import { PLVMarqueeDoubleMarqueeSubTextView } from './PLVMarqueeDoubleMarqueeSubTextView'
import { PLVMarqueeRollView } from './PLVMarqueeRollView'

@Component
export struct PLVMarqueeRollDoubleMarqueeView {
  model?: PLVMarqueeModel

  build() {
    Stack() {
      PLVMarqueeRollView({
        model: this.model
      })
      PLVMarqueeDoubleMarqueeSubTextView({
        model: this.model
      })
    }
  }
}