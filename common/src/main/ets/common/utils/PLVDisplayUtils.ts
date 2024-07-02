import display from '@ohos.display'

export function isPortrait() {
  const orientation = display.getDefaultDisplaySync().orientation
  return orientation === display.Orientation.PORTRAIT || orientation === display.Orientation.PORTRAIT_INVERTED
}

export function isLandscape() {
  const orientation = display.getDefaultDisplaySync().orientation
  return orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED
}

/**
 * display width
 * @returns width in px
 */
export function getDisplayWindowWidth() {
  return px(display.getDefaultDisplaySync().width)
}

/**
 * display height
 * @returns height in px
 */
export function getDisplayWindowHeight() {
  return px(display.getDefaultDisplaySync().height)
}

export class Pixels {
  constructor(
    readonly value: number
  ) {
  }

  get px() {
    return this.value
  }

  get vp() {
    return px2vp(this.value)
  }

  toString() {
    return `${this.value}px`
  }
}

export function px(value: number) {
  return new Pixels(value)
}

export class VirtualPixels {
  constructor(
    readonly value: number
  ) {
  }

  get px() {
    return vp2px(this.value)
  }

  get vp() {
    return this.value
  }

  toString() {
    return `${this.value}vp`
  }
}

export function vp(value: number) {
  return new VirtualPixels(value)
}

// <editor-fold defaultstate="collapsed" desc="ohos declare">

declare function px2vp(value: number): number;

declare function vp2px(value: number): number;

// </editor-fold>