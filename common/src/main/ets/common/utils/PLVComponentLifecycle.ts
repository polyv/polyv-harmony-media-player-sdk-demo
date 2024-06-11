import {MutableEvent, MutableState} from '@polyvharmony/media-player-sdk';

export class PLVComponentLifecycle {

  readonly state: MutableState<LifecycleState> = new MutableState<LifecycleState>(LifecycleState.INITIALIZED)
  readonly event: MutableEvent<LifecycleChangeEvent> = new MutableEvent()

  onAboutToAppear() {
    this.changeStateTo(LifecycleState.APPEARED)
  }

  onPageShow() {
    this.changeStateTo(LifecycleState.SHOWING)
  }

  onPageHide() {
    this.changeStateTo(LifecycleState.APPEARED)
  }

  onAboutToDisappear() {
    this.changeStateTo(LifecycleState.INITIALIZED)
  }

  private changeStateTo(state: LifecycleState) {
    this.event.value = new LifecycleChangeEvent(this.state.value!, state)
    this.state.value = state
  }

}

export enum LifecycleState {
  INITIALIZED = 0,
  APPEARED = 1,
  SHOWING = 2
}

export class LifecycleChangeEvent {

  constructor(
    readonly from: LifecycleState,
    readonly to: LifecycleState
  ) {
  }

}