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
export struct PLVMarqueeRollFlickerView {
  model?: PLVMarqueeModel
  @State textOpacity: number = 0
  @State isVisible: boolean = false
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
  private rollAnimate?: AnimatorResult = undefined
  private tweenAnimate?: AnimatorResult = undefined
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.animateSetting = requireNotNull(this.model).animateSetting
    this.textSetting = requireNotNull(this.model).mainTextSetting
    this.model?.playingState.observe((playingState) => {
      if (playingState === PLVMarqueePlayingState.PLAY) {
        this.rollAnimate?.play()
        this.tweenAnimate?.play()
      } else {
        this.rollAnimate?.pause()
        this.tweenAnimate?.pause()
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
        .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
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
    this.rollAnimate?.cancel()
    this.tweenAnimate?.cancel()
    this.rollAnimate = undefined
    this.tweenAnimate = undefined
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

  private prepareAnimate() {
    const containerWidth = this.containerWidth
    const containerHeight = this.containerHeight
    const textWidth = px2vp(this.textSizeOption.value.width as number)
    const textHeight = px2vp(this.textSizeOption.value.height as number)

    this.prepareRollAnimate(containerWidth, containerHeight, textWidth, textHeight)
    this.prepareTweenAnimate(containerWidth, containerHeight, textWidth, textHeight)

    this.textOffsetY = random(0, extendNumber(containerHeight - textHeight).coerceAtLeast_ext(0))
    if (this.model?.playingState.value === PLVMarqueePlayingState.PLAY) {
      this.rollAnimate?.play()
      this.tweenAnimate?.play()
    }
  }

  private prepareRollAnimate(containerWidth: number, containerHeight: number, textWidth: number, textHeight: number) {
    this.rollAnimate?.cancel()

    let startOffsetX = 0
    let endOffsetX = 0
    if (this.animateSetting.isAlwaysShowWhenRun) {
      if (containerWidth < textWidth) {
        startOffsetX = 0
        endOffsetX = containerWidth - textWidth
      } else {
        startOffsetX = containerWidth - textWidth
        endOffsetX = 0
      }
    } else {
      startOffsetX = containerWidth
      endOffsetX = -textWidth
    }

    const rollAnimOption: AnimatorOptions = {
      duration: this.animateSetting.rollTime.toMillis(),
      delay: 0,
      easing: 'linear',
      fill: "none",
      direction: "normal",
      iterations: 1,
      begin: startOffsetX,
      end: endOffsetX
    }
    this.rollAnimate = Animator.create(rollAnimOption)
    this.rollAnimate.onFrame = (value: number) => {
      this.isVisible = true
      this.textOffsetX = value
    }
    this.rollAnimate.onFinish = () => {
      this.isVisible = false
      rollAnimOption.delay = this.animateSetting.rollInterval.toMillis()
      this.rollAnimate?.reset(rollAnimOption)
      this.textOffsetY = random(0, extendNumber(containerHeight - textHeight).coerceAtLeast_ext(0))
      this.rollAnimate?.play()
    }
    this.rollAnimate.onCancel = () => {
      this.isVisible = false
    }
  }

  private prepareTweenAnimate(containerWidth: number, containerHeight: number, textWidth: number, textHeight: number) {
    this.tweenAnimate?.cancel()

    const minOpacity = this.animateSetting.isAlwaysShowWhenRun ? 0.1 : 0
    const maxOpacity = 1
    const tweenBeginValue = minOpacity
    const tweenEndValue = maxOpacity + (maxOpacity - minOpacity)

    const tweenAnimOption: AnimatorOptions = {
      duration: this.animateSetting.tweenTime.toMillis(),
      delay: 0,
      easing: 'linear',
      fill: "none",
      direction: "normal",
      iterations: 1,
      begin: tweenBeginValue,
      end: tweenEndValue
    }
    this.tweenAnimate = Animator.create(tweenAnimOption)
    this.tweenAnimate.onFrame = (value: number) => {
      this.textOpacity = maxOpacity - Math.abs(value - maxOpacity)
    }
    this.tweenAnimate.onFinish = () => {
      tweenAnimOption.delay = this.animateSetting.tweenInterval.toMillis()
      this.tweenAnimate?.reset(tweenAnimOption)
      this.tweenAnimate?.play()
    }
    this.tweenAnimate.onCancel = () => {
      this.textOpacity = 0
    }
  }
}