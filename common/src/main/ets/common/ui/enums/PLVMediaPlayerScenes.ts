import {PLVMediaResource} from '@polyvharmony/media-player-sdk'

export class PLVMediaPlayerScenes {
  readonly name: string

  private constructor(
    name: string
  ) {
    this.name = name
  }

  static readonly DOWNLOAD_CENTER = new PLVMediaPlayerScenes("scene_download_center")
  static readonly SINGLE_VIDEO = new PLVMediaPlayerScenes("scene_single_video")
  static readonly FEED_VIDEO = new PLVMediaPlayerScenes("scene_feed_video")

}

export abstract class PLVMediaPlayerScenePageParam {
}

export class PLVMediaPlayerDownloadCenterPageParam extends PLVMediaPlayerScenePageParam {
  constructor(
    readonly defaultTabIndex: number = 0
  ) {
    super()
  }
}

export class PLVMediaPlayerSingleVideoPageParam extends PLVMediaPlayerScenePageParam {
  constructor(
    readonly mediaResource: PLVMediaResource,
    readonly enterFromDownloadCenter: boolean = false
  ) {
    super();
  }
}

export class PLVMediaPlayerFeedVideoPageParam extends PLVMediaPlayerScenePageParam {
  constructor(
    readonly initialMediaSources: PLVMediaResource[]
  ) {
    super();
  }
}