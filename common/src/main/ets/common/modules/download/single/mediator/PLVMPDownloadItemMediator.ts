import {LifecycleAwareDependComponent, MutableSource, MutableState} from "@polyvharmony/media-player-sdk";
import {PLVMPDownloadItemViewState} from "../viewmodel/viewstate/PLVMPDownloadItemViewState";

export class PLVMPDownloadItemMediator implements LifecycleAwareDependComponent {

  readonly downloadItem = new MutableState<PLVMPDownloadItemViewState | null>(null)

  onDestroy() {
    MutableSource.disposeAll(this)
  }

}