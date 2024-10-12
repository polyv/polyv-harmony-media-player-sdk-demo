import {PLVMPAuxiliaryRepo} from "../../model/PLVMPAuxiliaryRepo";
import {LifecycleAwareDependComponent, MutableObserver} from '@polyvharmony/media-player-sdk';

export class AuxiliaryUpdateMediaStateUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPAuxiliaryRepo

  private observers: MutableObserver[] = []

  constructor(
    repo: PLVMPAuxiliaryRepo
  ) {
    this.repo = repo

    this.observeState()
  }

  private observeState() {
    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onShowAdvertEvent.observe((event) => {
      this.repo.mediator.auxiliaryInfoViewState.value = {
        stage: event.stage,
        ...event.dataSource
      }
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onFinishAdvertEvent.observe(() => {
      this.repo.mediator.auxiliaryInfoViewState.value = null
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getStateListenerRegistry().videoSize.observe((videoSize) => {
      this.repo.mediator.auxiliaryVideoInfoViewState.mutate({
        videoSize: videoSize
      })
    }).pushTo(this.observers)

    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onTimeLeftCountDownEvent.observe((event) => {
      this.repo.mediator.auxiliaryPlayViewState.mutate({
        timeLeftInSeconds: event.timeLeftInSeconds
      })
    }).pushTo(this.observers)
  }

  onDestroy() {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}