import AbilityStage from '@ohos.app.ability.AbilityStage';
import { PLVMediaPlayerStartUp } from './startup/PLVMediaPlayerStartUp';
import contextConstant from '@ohos.app.ability.contextConstant';

export default class PLVMediaPlayerAbilityStage extends AbilityStage {
  onCreate(): void {
    this.context.area = contextConstant.AreaMode.EL2
    PLVMediaPlayerStartUp.start(this.context)
  }
}