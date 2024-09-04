import {
  extendNumber,
  lateInit,
  Lazy,
  lazy,
  MutableObserver,
  random,
  requireNotNull
} from '@polyvharmony/media-player-sdk'
import { PLVMarqueeModel, PLVMarqueePlayingState } from '../model/PLVMarqueeModel'
import MeasureText from '@ohos.measure'
import { PLVMarqueeTextSettingVO } from '../model/PLVMarqueeTextSettingVO'
import { PLVMarqueeAnimateSettingVO } from '../model/PLVMarqueeAnimateSettingVO'
import Animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator'

@Component
export struct PLVMarqueeFlickerView {
  model?: PLVMarqueeModel
  @State textOpacity: number = 0
  @State textOffsetX: number = 0
  @State textOffsetY: number = 0
  private animateSetting: PLVMarqueeAnimateSettingVO = lateInit()
  private textSetting: PLVMarqueeTextSettingVO = lateInit()
  private textSizeOption: Lazy<SizeOptions> = lazy(() => MeasureText.measureTextSize({
    textContent: this.textSetting.content,
    fontSize: this.textSetting.fontSize
  }))
  private containerWidth: number = 0
  private containerHeight: number = 0
  private marqueeAnimate?: AnimatorResult = undefined
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.animateSetting = requireNotNull(this.model).animateSetting
    this.textSetting = requireNotNull(this.model).mainTextSetting
    this.model?.playingState.observe((playingState) => {
      if (playingState === PLVMarqueePlayingState.PLAY) {
        this.marqueeAnimate?.play()
      } else {
        this.marqueeAnimate?.pause()
      }
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      Text(this.textSetting.content)
        .width(px2vp(this.textSizeOption.value.width as number))
        .height(px2vp(this.textSizeOption.value.height as number))
        .fontColor(this.textSetting.fontColor)
        .fontSize(this.textSetting.fontSize)
        .maxLines(1)
        .textShadow({
          radius: this.textSetting.isShadow ? this.textSetting.shadowRadius : 0,
          color: this.textSetting.isShadow ? this.textSetting.shadowColor : undefined,
          offsetX: this.textSetting.isShadow ? this.textSetting.shadowOffsetX : undefined,
          offsetY: this.textSetting.isShadow ? this.textSetting.shadowOffsetY : undefined,
        })
        .opacity(this.textOpacity)
        .offset({
          x: this.textOffsetX,
          y: this.textOffsetY
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onAreaChange((_, newArea) => {
      this.containerWidth = newArea.width as number
      this.containerHeight = newArea.height as number
      this.prepareAnimate()
    })
  }

  aboutToDisappear(): void {
    this.marqueeAnimate?.cancel()
    this.marqueeAnimate = undefined
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

  private prepareAnimate() {
    const containerWidth = this.containerWidth
    const containerHeight = this.containerHeight
    const textWidth = px2vp(this.textSizeOption.value.width as number)
    const textHeight = px2vp(this.textSizeOption.value.height as number)
    this.marqueeAnimate?.cancel()

    const minOpacity = this.animateSetting.isAlwaysShowWhenRun ? 0.1 : 0
    const maxOpacity = 1
    const beginValue = minOpacity
    const endValue = maxOpacity + (maxOpacity - minOpacity)

    const animOption: AnimatorOptions = {
      duration: this.animateSetting.tweenTime.toMillis(),
      delay: 0,
      easing: 'linear',
      fill: "none",
      direction: "normal",
      iterations: 1,
      begin: beginValue,
      end: endValue
    }
    this.marqueeAnimate = Animator.create(animOption)
    this.marqueeAnimate.onFrame = (value: number) => {
      this.textOpacity = maxOpacity - Math.abs(value - maxOpacity)
    }
    this.marqueeAnimate.onFinish = () => {
      animOption.delay = this.animateSetting.tweenInterval.toMillis()
      this.marqueeAnimate?.reset(animOption)
      this.textOffsetX = random(0, extendNumber(containerWidth - textWidth).coerceAtLeast_ext(0))
      this.textOffsetY = random(0, extendNumber(containerHeight - textHeight).coerceAtLeast_ext(0))
      this.marqueeAnimate?.play()
    }
    this.marqueeAnimate.onCancel = () => {
      this.textOpacity = 0
    }

    this.textOffsetX = random(0, extendNumber(containerWidth - textWidth).coerceAtLeast_ext(0))
    this.textOffsetY = random(0, extendNumber(containerHeight - textHeight).coerceAtLeast_ext(0))
    if (this.model?.playingState.value === PLVMarqueePlayingState.PLAY) {
      this.marqueeAnimate?.play()
    }
  }
}