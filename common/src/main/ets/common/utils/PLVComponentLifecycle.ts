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

  onPageHide(isWindowHidden: boolean = false) {
    this.changeStateTo(LifecycleState.APPEARED, isWindowHidden)
  }

  onAboutToDisappear() {
    this.changeStateTo(LifecycleState.INITIALIZED)
  }

  private changeStateTo(state: LifecycleState, isWindowHidden: boolean = false) {
    this.event.value = new LifecycleChangeEvent(this.state.value!, state, isWindowHidden)
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
    readonly to: LifecycleState,
    // 导航页仍在栈顶，只是应用窗口进入后台。
    readonly isWindowHidden: boolean = false
  ) {
  }

}