export class PLVMarqueeTextSettingVO {

  // 跑马灯文本内容
  content: string = ""
  // 跑马灯文字颜色
  fontColor: string = '#000000'
  // 跑马灯文字大小
  fontSize: number = 16
  // 是否显示阴影
  isShadow: boolean = false
  // 阴影颜色
  shadowColor: string = '#000000'
  // 阴影偏移X
  shadowOffsetX: number = 0
  // 阴影偏移Y
  shadowOffsetY: number = 0
  // 阴影模糊半径
  shadowRadius: number = 0

  setContent(content: string) {
    this.content = content
    return this
  }

  setFontColor(fontColor: string) {
    this.fontColor = fontColor
    return this
  }

  setFontSize(fontSize: number) {
    this.fontSize = fontSize
    return this
  }

  setShadow(isShadow: boolean) {
    this.isShadow = isShadow
    return this
  }

  setShadowColor(shadowColor: string) {
    this.shadowColor = shadowColor
    return this
  }

  setShadowOffsetX(shadowOffsetX: number) {
    this.shadowOffsetX = shadowOffsetX
    return this
  }

  setShadowOffsetY(shadowOffsetY: number) {
    this.shadowOffsetY = shadowOffsetY
    return this
  }

  setShadowRadius(shadowRadius: number) {
    this.shadowRadius = shadowRadius
    return this
  }

}