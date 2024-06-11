import {PLVMediaBitRate, PLVMediaOutputMode, Rect} from '@polyvharmony/media-player-sdk'

export class PLVMPMediaInfoViewState {
  title: string = ""
  videoSize: Rect = new Rect()
  bitRate: PLVMediaBitRate | null = null
  supportBitRates: PLVMediaBitRate[] = []
  outputMode: PLVMediaOutputMode = PLVMediaOutputMode.AUDIO_VIDEO
  supportOutputModes: PLVMediaOutputMode[] = []
  progressPreviewImage: string | null = null
  progressPreviewImageInterval: number = -1
  audioModeCoverImage: string | null = null
}