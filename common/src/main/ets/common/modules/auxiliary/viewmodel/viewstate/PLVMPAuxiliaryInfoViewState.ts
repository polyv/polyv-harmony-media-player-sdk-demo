import {Duration, PLVMediaPlayStage, seconds} from '@polyvharmony/media-player-sdk';

export class PLVMPAuxiliaryInfoViewState {

  url: string = ""
  isImage: boolean = false
  clickNavigationUrl: string | null = null
  showDuration: Duration = seconds(0)
  canSkip: boolean = false
  beforeSkipDuration: Duration | null = null
  stage: PLVMediaPlayStage = PLVMediaPlayStage.HEAD_ADVERT

}