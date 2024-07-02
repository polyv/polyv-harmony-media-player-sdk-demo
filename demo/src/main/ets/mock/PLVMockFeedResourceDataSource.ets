import { IPLVMediaPlayerFeedResourceDataSource } from 'scene_feed_video';
import { PLVMediaResource } from '@polyvharmony/media-player-sdk';
import { PLVMockMediaResourceData } from './PLVMockMediaResourceData';

export class PLVMockFeedResourceDataSource implements IPLVMediaPlayerFeedResourceDataSource {
  async onLoadMoreData(fromIndex: number): Promise<PLVMediaResource[]> {
    const result = await PLVMockMediaResourceData.getInstance().getMediaResources();
    return result.slice(fromIndex, fromIndex + 5);
  }
}