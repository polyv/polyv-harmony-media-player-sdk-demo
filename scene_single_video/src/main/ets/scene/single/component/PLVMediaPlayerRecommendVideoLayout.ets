import {
  delay,
  DependScope,
  lateInit,
  MutableObserver,
  PLVGeneralApiManager,
  PLVMediaPlayerState,
  PLVMediaResource,
  PLVMediaResources,
  PLVVodMediaResource,
  Promises,
  runCatching,
  watchStates
} from '@polyvharmony/media-player-sdk'
import {
  defineIds,
  formatDuration,
  LifecycleState,
  parent,
  PLVFullUpdateDataSource,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
  PLVMPMediaViewModel,
  PLVMPPageControlViewModel,
  toBottomOf,
  toEndOf,
  toStartOf,
  toTopOf,
  usePadding
} from 'media-player-common'

@Component
export struct PLVMediaPlayerRecommendVideoLayout {
  recommendVideos: PLVMediaResource[] = []
  @Consume pageDependScope: DependScope
  private readonly pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  @Consume dependScope: DependScope
  private readonly viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel);
  private readonly dataSource = new PLVFullUpdateDataSource<PLVMediaResource>()
  private isPausePlayerWhenGoToOtherVideo: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    const waitMediaPrepared = Promises.withResolvers<void>()
    watchStates(() => {
      const playerState = this.viewModel.playerState.value ?? PLVMediaPlayerState.STATE_IDLE
      if (playerState >= PLVMediaPlayerState.STATE_PREPARED) {
        waitMediaPrepared.resolve()
      }
    }).pushTo(this.observers)
    Promises.launch(async () => {
      // 延迟初始化，避免影响视频加载速度
      await Promise.race([
        waitMediaPrepared.promise,
        delay(2000)
      ])
      this.dataSource.update(this.recommendVideos)
    })

    this.pageControlViewModel.pageLifecycle.event.observe(event => {
      if (event.to == LifecycleState.SHOWING) {
        if (this.isPausePlayerWhenGoToOtherVideo) {
          this.viewModel.start()
          this.isPausePlayerWhenGoToOtherVideo = false
        }
      }
    })
      .pushTo(this.observers)
    watchStates(() => {
      const playerState = this.viewModel.playerState.value ?? PLVMediaPlayerState.STATE_IDLE
      if (this.isPausePlayerWhenGoToOtherVideo) {
        if ([PLVMediaPlayerState.STATE_PREPARED, PLVMediaPlayerState.STATE_PLAYING].includes(playerState)) {
          this.viewModel.pause()
        }
      }
    }).pushTo(this.observers)
  }

  build() {
    List() {
      LazyForEach(
        this.dataSource,
        (mediaResource: PLVMediaResource) => {
          ListItem() {
            RecommendVideoItem({
              mediaResource: mediaResource,
              onNavigateToRecommendVideo: this.onNavigateToRecommendVideo
            })
          }
        },
        (_: PLVMediaResource, index) => index.toString()
      )
    }
    .width('100%')
    .height('100%')
  }

  private onNavigateToRecommendVideo = (mediaResource: PLVMediaResource) => {
    const navPathStack: NavPathStack = this.pageControlViewModel.navPathStack
    navPathStack.pushPath(new NavPathInfo(
      PLVMediaPlayerScenes.SINGLE_VIDEO.name,
      new PLVMediaPlayerSingleVideoPageParam(mediaResource)
    ))
    const playerState = this.viewModel.playerState.value ?? PLVMediaPlayerState.STATE_IDLE
    const playerStatesToPause = [PLVMediaPlayerState.STATE_IDLE, PLVMediaPlayerState.STATE_PREPARING, PLVMediaPlayerState.STATE_PREPARED, PLVMediaPlayerState.STATE_PLAYING]
    const isPausePlayer = playerStatesToPause.includes(playerState)
    if (isPausePlayer) {
      this.viewModel.pause()
      this.isPausePlayerWhenGoToOtherVideo = true
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }

}

@Component
struct RecommendVideoItem {
  mediaResource: PLVMediaResource = lateInit()
  onNavigateToRecommendVideo: (mediaResource: PLVMediaResource) => void = lateInit()
  @State private coverImage: string = ''
  @State private title: string = ''
  @State private duration: string = ''
  @State private isVisible: boolean = false
  private readonly ids = defineIds(
    'plv_media_player_recommend_video_cover_image',
    'plv_media_player_recommend_video_title',
    'plv_media_player_recommend_video_duration'
  )

  aboutToAppear(): void {
    if (PLVMediaResources.isVodMediaResource(this.mediaResource)) {
      this.initVodMediaResource(this.mediaResource)
    }
  }

  private async initVodMediaResource(mediaResource: PLVVodMediaResource) {
    const videoJson = await runCatching(PLVGeneralApiManager.getVideoJson(mediaResource))
    if (videoJson.success === false) {
      return
    }
    this.coverImage = videoJson.data.first_image ?? ''
    this.title = videoJson.data.title ?? ''
    this.duration = formatDuration(videoJson.data.durationSeconds * 1000)
    this.isVisible = true
  }

  build() {
    Column() {
      RelativeContainer() {
        Image(this.coverImage)
          .id(this.ids.plv_media_player_recommend_video_cover_image)
          .width(128)
          .height(72)
          .borderRadius(4)
          .alignRules({
            start: toStartOf(parent),
            top: toTopOf(parent),
            bottom: toBottomOf(parent)
          })

        Text(this.title)
          .id(this.ids.plv_media_player_recommend_video_title)
          .alignRules({
            top: toTopOf(this.ids.plv_media_player_recommend_video_cover_image),
            start: toEndOf(this.ids.plv_media_player_recommend_video_cover_image),
            end: toEndOf(parent)
          })
          .fontSize(14)
          .fontColor('#F0F1F5')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .ellipsisMode(EllipsisMode.END)
          .margin({
            left: 8
          })

        Text(this.duration)
          .id(this.ids.plv_media_player_recommend_video_duration)
          .alignRules({
            bottom: toBottomOf(this.ids.plv_media_player_recommend_video_cover_image),
            start: toEndOf(this.ids.plv_media_player_recommend_video_cover_image),
            end: toEndOf(parent)
          })
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .ellipsisMode(EllipsisMode.END)
          .margin({
            left: 8
          })
      }
      .width('100%')
      .height(88)
      .padding(usePadding({
        vertical: 8
      }))

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#666666')
    }
    .width('100%')
    .padding(usePadding({
      horizontal: 16
    }))
    .onClick(() => {
      this.onNavigateToRecommendVideo(this.mediaResource)
    })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }
}