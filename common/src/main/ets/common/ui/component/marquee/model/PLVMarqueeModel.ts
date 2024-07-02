import {MutableState} from '@polyvharmony/media-player-sdk';
import {PLVMarqueeAnimateSettingVO} from "./PLVMarqueeAnimateSettingVO";
import {PLVMarqueeTextSettingVO} from "./PLVMarqueeTextSettingVO";

export class PLVMarqueeModel {

  readonly animateSetting: PLVMarqueeAnimateSettingVO
  readonly mainTextSetting: PLVMarqueeTextSettingVO
  readonly subTextSetting?: PLVMarqueeTextSettingVO
  // 控制跑马灯播放暂停
  readonly playingState: MutableState<PLVMarqueePlayingState> = new MutableState(PLVMarqueePlayingState.PLAY)

  constructor(
    animateSetting: PLVMarqueeAnimateSettingVO,
    mainTextSetting: PLVMarqueeTextSettingVO,
    subTextSetting?: PLVMarqueeTextSettingVO
  ) {
    this.animateSetting = animateSetting
    this.mainTextSetting = mainTextSetting
    this.subTextSetting = subTextSetting
  }

  setPlayingState(playingState: PLVMarqueePlayingState) {
    this.playingState.value = playingState
  }

}

export enum PLVMarqueePlayingState {
  PLAY = 1,
  PAUSE = 2
}