import AbilityStage from '@ohos.app.ability.AbilityStage';
import { PLVMediaPlayerStartUp } from './startup/PLVMediaPlayerStartUp';

export default class PLVMediaPlayerAbilityStage extends AbilityStage {
  onCreate(): void {
    PLVMediaPlayerStartUp.start(this.context)
  }
}