import { derivedStateOf, mutableStateOf } from '@polyvharmony/media-player-sdk'
import { vp } from './PLVDisplayUtils'

export class PLVKeyboardManager {
  private static readonly instance = new PLVKeyboardManager()

  private constructor() {
  }

  static getInstance() {
    return PLVKeyboardManager.instance
  }

  readonly keyboardHeight = mutableStateOf(vp(0))
  readonly keyboardVisible = derivedStateOf(() => (this.keyboardHeight.value?.value ?? 0) > 0)
}