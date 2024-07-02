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
export struct PLVMarqueeRollView {
  model?: PLVMarqueeModel
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
        .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
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
    const textWidth = px2vp(this.textSizeOption.value.width as number)
    const textHeight = px2vp(this.textSizeOption.value.height as number)
    this.marqueeAnimate?.cancel()

    let startOffsetX = 0
    let endOffsetX = 0
    if (this.animateSetting.isAlwaysShowWhenRun) {
      if (this.containerWidth < textWidth) {
        startOffsetX = 0
        endOffsetX = this.containerWidth - textWidth
      } else {
        startOffsetX = this.containerWidth - textWidth
        endOffsetX = 0
      }
    } else {
      startOffsetX = this.containerWidth
      endOffsetX = -textWidth
    }

    const animOption: AnimatorOptions = {
      duration: this.animateSetting.rollTime.toMillis(),
      delay: 0,
      easing: 'linear',
      fill: "none",
      direction: "normal",
      iterations: 1,
      begin: startOffsetX,
      end: endOffsetX
    }
    this.marqueeAnimate = Animator.create(animOption)
    this.marqueeAnimate.onframe = (value: number) => {
      this.isVisible = true
      this.textOffsetX = value
    }
    this.marqueeAnimate.onfinish = () => {
      this.isVisible = false
      animOption.delay = this.animateSetting.rollInterval.toMillis()
      this.marqueeAnimate?.reset(animOption)
      this.textOffsetY = random(0, extendNumber(this.containerHeight - textHeight).coerceAtLeast_ext(0))
      this.marqueeAnimate?.play()
    }
    this.marqueeAnimate.oncancel = () => {
      this.isVisible = false
    }

    this.textOffsetY = random(0, extendNumber(this.containerHeight - textHeight).coerceAtLeast_ext(0))
    if (this.model?.playingState.value === PLVMarqueePlayingState.PLAY) {
      this.marqueeAnimate?.play()
    }
  }
}