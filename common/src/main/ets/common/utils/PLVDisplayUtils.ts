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
  return display.getDefaultDisplaySync().width
}

/**
 * display height
 * @returns height in px
 */
export function getDisplayWindowHeight() {
  return display.getDefaultDisplaySync().height
}