import { mutableStateOf } from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerKnowledgeVO } from './vo/PLVMediaPlayerKnowledgeVO';

export class PLVMediaPlayerKnowledgeViewModel {
  readonly knowledgeData = mutableStateOf<PLVMediaPlayerKnowledgeVO>()

  setKnowledgeData(data: PLVMediaPlayerKnowledgeVO) {
    this.knowledgeData.setValue(data)
  }
}