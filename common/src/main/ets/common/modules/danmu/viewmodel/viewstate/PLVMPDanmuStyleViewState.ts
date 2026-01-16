import { PLVMediaPlayerDanmuMode } from '@polyvharmony/media-player-sdk-addon-business'

export class PLVMPDanmuStyleViewState {
  color: number = 0xFFFFFFFF
  size: PLVMPDanmuSize = PLVMPDanmuSize.MEDIUM
  mode: PLVMediaPlayerDanmuMode = PLVMediaPlayerDanmuMode.ROLL_RIGHT_TO_LEFT
}

export class PLVMPDanmuSize {
  private constructor(
    readonly value: number
  ) {
  }

  static readonly SMALL = new PLVMPDanmuSize(16)
  static readonly MEDIUM = new PLVMPDanmuSize(18)
  static readonly LARGE = new PLVMPDanmuSize(24)
}