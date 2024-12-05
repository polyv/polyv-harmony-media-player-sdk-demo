import {MutableState, OnBackPressHandler} from '@polyvharmony/media-player-sdk';
import {PLVComponentLifecycle} from "../../../utils/PLVComponentLifecycle";

export class PLVMPPageControlViewModel {

  readonly currentItemIndex: MutableState<number> = new MutableState(0)
  readonly pageLifecycle: PLVComponentLifecycle = new PLVComponentLifecycle()
  readonly onBackPressHandler = new OnBackPressHandler()
  navPathStack?: any | undefined = undefined

  onCurrentItemChanged(currentIndex: number) {
    this.currentItemIndex.value = currentIndex
  }

}