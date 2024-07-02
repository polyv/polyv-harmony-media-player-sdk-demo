import {PLVMPAuxiliaryRepo} from "../../model/PLVMPAuxiliaryRepo";
import {LifecycleAwareDependComponent, MutableObserver, MutableState} from '@polyvharmony/media-player-sdk';
import {PLVMPAuxiliaryVideoInfoViewState} from "../viewstate/PLVMPAuxiliaryVideoInfoViewState";
import {PLVMPAuxiliaryPlayViewState} from "../viewstate/PLVMPAuxiliaryPlayViewState";
import {PLVMPAuxiliaryInfoViewState} from "../viewstate/PLVMPAuxiliaryInfoViewState";

export class AuxiliaryUpdateMediaStateUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPAuxiliaryRepo

  readonly auxiliaryInfoViewState: MutableState<PLVMPAuxiliaryInfoViewState | null> = new MutableState<PLVMPAuxiliaryInfoViewState | null>(null);
  readonly auxiliaryPlayViewState = new MutableState<PLVMPAuxiliaryPlayViewState>(new PLVMPAuxiliaryPlayViewState());
  readonly auxiliaryVideoInfoViewState = new MutableState<PLVMPAuxiliaryVideoInfoViewState>(new PLVMPAuxiliaryVideoInfoViewState());

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPAuxiliaryRepo
  ) {
    this.repo = repo

    this.observeState()
  }

  private observeState() {
    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onShowAdvertEvent.observe((event) => {
      this.auxiliaryInfoViewState.value = {
        stage: event.stage,
        ...event.dataSource
      }
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onFinishAdvertEvent.observe(() => {
      this.auxiliaryInfoViewState.value = null
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getStateListenerRegistry().videoSize.observe((videoSize) => {
      this.auxiliaryVideoInfoViewState.mutate({
        videoSize: videoSize
      })
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onTimeLeftCountDownEvent.observe((event) => {
      this.auxiliaryPlayViewState.mutate({
        timeLeftInSeconds: event.timeLeftInSeconds
      })
    }).pushTo(this.observers)
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}