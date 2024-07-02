import {MutableState} from '@polyvharmony/media-player-sdk';
import {PLVComponentLifecycle} from "../../../utils/PLVComponentLifecycle";

export class PLVMPPageControlViewModel {

  readonly currentItemIndex: MutableState<number> = new MutableState(0)
  readonly pageLifecycle: PLVComponentLifecycle = new PLVComponentLifecycle()
  navPathStack?: any | undefined = undefined

  onCurrentItemChanged(currentIndex: number) {
    this.currentItemIndex.value = currentIndex
  }

}