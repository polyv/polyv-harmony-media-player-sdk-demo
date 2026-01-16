export class DanmakuFlameMasterExtends {
  static fixBottomDanmakuNotVisible(baseDanmaku: any) {
    if (baseDanmaku.getType() != 4) {
      return
    }
    const origin: Function = baseDanmaku.getBottom
    baseDanmaku.getBottom = () => {
      const bottom = origin.call(baseDanmaku)
      return bottom - 1e-6
    }
  }

  static fixDanmakuNotRenderWhenEmit(danmakuModel: any) {
    if (danmakuModel['delegate']?.['handler']?.['mRenderingState']?.['nothingRendered'] !== undefined) {
      danmakuModel['delegate']['handler']['mRenderingState']['nothingRendered'] = false
    }
  }
}