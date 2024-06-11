import common from '@ohos.app.ability.common';
import {extendArray} from '@polyvharmony/media-player-sdk';

export class PLVAbilityContexts {

  // <editor-fold defaultstate="collapsed" desc="单例">

  private static readonly instance = new PLVAbilityContexts()

  private constructor() {
  }

  static getInstance() {
    return PLVAbilityContexts.instance
  }

  // </editor-fold>

  private readonly uiAbilityContexts: common.UIAbilityContext[] = []

  registerContext(context: common.UIAbilityContext) {
    this.uiAbilityContexts.push(context)
  }

  unregisterContext(context: common.UIAbilityContext) {
    extendArray(this.uiAbilityContexts).remove_ext(context)
  }

  lastContext(): common.UIAbilityContext | undefined {
    return this.uiAbilityContexts[this.uiAbilityContexts.length - 1]
  }

}