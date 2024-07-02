import {PLVMediaResource} from '@polyvharmony/media-player-sdk'

export class PLVMediaPlayerScenes {
  readonly name: string

  private constructor(
    name: string
  ) {
    this.name = name
  }

  static readonly SINGLE_VIDEO = new PLVMediaPlayerScenes("scene_single_video")
  static readonly FEED_VIDEO = new PLVMediaPlayerScenes("scene_feed_video")

}

export abstract class PLVMediaPlayerScenePageParam {
}

export class PLVMediaPlayerSingleVideoPageParam extends PLVMediaPlayerScenePageParam {
  readonly mediaResource: PLVMediaResource

  constructor(
    mediaResource: PLVMediaResource
  ) {
    super();
    this.mediaResource = mediaResource
  }
}

export class PLVMediaPlayerFeedVideoPageParam extends PLVMediaPlayerScenePageParam {
  readonly initialMediaSources: PLVMediaResource[]

  constructor(
    initialMediaSources: PLVMediaResource[]
  ) {
    super();
    this.initialMediaSources = initialMediaSources
  }
}