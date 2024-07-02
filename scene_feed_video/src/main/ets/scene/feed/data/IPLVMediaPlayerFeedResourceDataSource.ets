import { PLVMediaResource } from '@polyvharmony/media-player-sdk'

export interface IPLVMediaPlayerFeedResourceDataSource {

  onLoadMoreData(fromIndex: number): Promise<PLVMediaResource[]>

}