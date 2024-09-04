import {PLVMediaBitRate, PLVMediaOutputMode, PLVMediaSubtitle, Rect} from '@polyvharmony/media-player-sdk'

export class PLVMPMediaInfoViewState {
  title: string = ""
  videoSize: Rect = new Rect()
  bitRate: PLVMediaBitRate | null = null
  supportBitRates: PLVMediaBitRate[] = []
  outputMode: PLVMediaOutputMode = PLVMediaOutputMode.AUDIO_VIDEO
  supportOutputModes: PLVMediaOutputMode[] = []
  currentSubtitle: PLVMediaSubtitle[] | null = null
  supportSubtitles: PLVMediaSubtitle[][] = []
  progressPreviewImage: string | null = null
  progressPreviewImageInterval: number = -1
  audioModeCoverImage: string | null = null
  topSubtitleTextStyle: PLVMPSubtitleTextStyle = new PLVMPSubtitleTextStyle()
  bottomSubtitleTextStyle: PLVMPSubtitleTextStyle = new PLVMPSubtitleTextStyle()
}

export class PLVMPSubtitleTextStyle {
  fontColor: string = "#FFFFFF"
  isBold: boolean = false
  isItalic: boolean = false
  backgroundColor: string = "#000000"
}