import {
  LifecycleAwareDependComponent,
  MutableEvent,
  MutableSource,
  MutableState,
  PLVMediaPlayerBusinessErrorEnum
} from "@polyvharmony/media-player-sdk";
import {PLVMPMediaControllerViewState} from "../viewmodel/viewstate/PLVMPMediaControllerViewState";

export class PLVMPMediaControllerMediator implements LifecycleAwareDependComponent {

  readonly mediaControllerViewState = new MutableState<PLVMPMediaControllerViewState>(new PLVMPMediaControllerViewState())
  // 亮度更新事件，范围 0.0 ~ 1.0
  readonly brightnessUpdateEvent = new MutableEvent<number>()
  // 音量更新事件，范围 0 ~ 100
  readonly volumeUpdateEvent = new MutableEvent<number>()
  readonly businessErrorState = new MutableState<PLVMediaPlayerBusinessErrorEnum | null>(null)
  readonly playCompleteState = new MutableState<boolean>(false)

  onDestroy() {
    MutableSource.disposeAll(this)
  }

}