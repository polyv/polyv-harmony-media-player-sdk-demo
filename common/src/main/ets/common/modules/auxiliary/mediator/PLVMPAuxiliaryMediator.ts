import {LifecycleAwareDependComponent, MutableSource, MutableState} from "@polyvharmony/media-player-sdk";
import {PLVMPAuxiliaryInfoViewState} from "../viewmodel/viewstate/PLVMPAuxiliaryInfoViewState";
import {PLVMPAuxiliaryPlayViewState} from "../viewmodel/viewstate/PLVMPAuxiliaryPlayViewState";
import {PLVMPAuxiliaryVideoInfoViewState} from "../viewmodel/viewstate/PLVMPAuxiliaryVideoInfoViewState";

export class PLVMPAuxiliaryMediator implements LifecycleAwareDependComponent {

  readonly auxiliaryInfoViewState = new MutableState<PLVMPAuxiliaryInfoViewState | null>(null);
  readonly auxiliaryPlayViewState = new MutableState<PLVMPAuxiliaryPlayViewState>(new PLVMPAuxiliaryPlayViewState());
  readonly auxiliaryVideoInfoViewState = new MutableState<PLVMPAuxiliaryVideoInfoViewState>(new PLVMPAuxiliaryVideoInfoViewState());

  onDestroy() {
    MutableSource.disposeAll(this)
  }

}