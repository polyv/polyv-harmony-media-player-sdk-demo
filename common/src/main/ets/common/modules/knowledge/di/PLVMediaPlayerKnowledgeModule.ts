import { DependModule } from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerKnowledgeViewModel } from '../PLVMediaPlayerKnowledgeViewModel';

export const knowledgeModule = new DependModule()

knowledgeModule.provide(PLVMediaPlayerKnowledgeViewModel, () => new PLVMediaPlayerKnowledgeViewModel())