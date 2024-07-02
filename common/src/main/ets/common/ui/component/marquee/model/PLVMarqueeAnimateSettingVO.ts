import {Duration, seconds} from '@polyvharmony/media-player-sdk';

export class PLVMarqueeAnimateSettingVO {

  // 动画类型
  animateType: PLVMarqueeAnimateType = PLVMarqueeAnimateType.ROLL
  // 滚动类型跑马灯完整显示一次的时长
  rollTime: Duration = seconds(0)
  // 滚动类型跑马灯两次显示之间的间隔时长
  rollInterval: Duration = seconds(0)
  // 闪烁类型跑马灯一次完整闪烁的时长
  tweenTime: Duration = seconds(0)
  // 闪烁类型跑马灯两次显示之间的间隔时长
  tweenInterval: Duration = seconds(0)
  // 暂停时是否显示跑马灯
  isHiddenWhenPause: boolean = true
  // 是否在屏幕区域内显示完整的跑马灯
  isAlwaysShowWhenRun: boolean = false

  setAnimateType(animateType: PLVMarqueeAnimateType) {
    this.animateType = animateType
    return this
  }

  setRollTime(duration: Duration) {
    this.rollTime = duration
    return this
  }

  setRollInterval(interval: Duration) {
    this.rollInterval = interval
    return this
  }

  setTweenTime(tweenTime: Duration) {
    this.tweenTime = tweenTime
    return this
  }

  setTweenInterval(tweenInterval: Duration) {
    this.tweenInterval = tweenInterval
    return this
  }

  setHiddenWhenPause(isHiddenWhenPause: boolean) {
    this.isHiddenWhenPause = isHiddenWhenPause
    return this
  }

  setAlwaysShowWhenRun(isAlwaysShowWhenRun: boolean) {
    this.isAlwaysShowWhenRun = isAlwaysShowWhenRun
    return this
  }

}

export enum PLVMarqueeAnimateType {
  // 滚动
  ROLL = 1,
  // 闪烁
  FLICKER = 2,
  // 滚动+闪烁
  ROLL_FLICKER = 3,
  // 滚动，限制在屏幕上下15%高度范围内
  ROLL_15PERCENT = 4,
  // 闪烁，限制在屏幕上下15%高度范围内
  FLICKER_15PERCENT = 5,
  // 滚动双跑马灯
  ROLL_DOUBLE_MARQUEE = 6,
  // 闪烁双跑马灯
  FLICKER_DOUBLE_MARQUEE = 7
}