import {
  IPLVAuxiliaryOnBeforeAdvertListener,
  PLVAdvertMediaDataSource,
  PLVMediaPlayStage
} from '@polyvharmony/media-player-sdk';

export class AuxiliaryBeforePlayListener implements IPLVAuxiliaryOnBeforeAdvertListener {

  private readonly playedAdvertIds = new Set<string>()

  onBeforeAdvert(dataSource: PLVAdvertMediaDataSource, stage: PLVMediaPlayStage): boolean {
    let playAdvert = true

    // 已播放过的片头片尾广告，不再播放
    if (stage === PLVMediaPlayStage.HEAD_ADVERT || stage === PLVMediaPlayStage.TAIL_ADVERT) {
      if (this.playedAdvertIds.has(dataSource.advertId)) {
        playAdvert = false
      } else {
        this.playedAdvertIds.add(dataSource.advertId)
      }
    }

    return playAdvert
  }

}