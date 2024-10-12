import {
  createDependScope,
  DependScope,
  MutableObserver,
  PLVMediaPlayerOptionEnum,
  PLVMediaResource,
  requireNotNull
} from '@polyvharmony/media-player-sdk';
import {
  commonItemModule,
  createId,
  getDisplayWindowHeight,
  getDisplayWindowWidth,
  isPortrait,
  parent,
  PLVMediaPlayerHandleOnEnterBackgroundComponent,
  PLVMediaPlayerPlayCompleteAutoRestartComponent,
  PLVMPMediaControllerViewModel,
  PLVMPMediaViewModel,
  PLVMPPageControlViewModel,
  PLVOrientationManager,
  toCenterOf,
  toMiddleOf
} from 'media-player-common';
import { PLVMediaPlayerFeedVideoStateHandleComponent } from './component/PLVMediaPlayerFeedVideoStateHandleComponent';
import { PLVMediaPlayerFeedVideoControllerLayout } from './layout/PLVMediaPlayerFeedVideoControllerLayout';
import { PLVMediaPlayerFeedVideoFloatActionLayout } from './layout/PLVMediaPlayerFeedVideoFloatActionLayout';

@Preview
@Component
export struct PLVMediaPlayerFeedVideoLayout {
  mediaResource?: PLVMediaResource
  mediaResourceIndex?: number
  @Provide dependScope: DependScope = createDependScope(commonItemModule)
  @Consume pageDependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel);
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel);
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  @State videoWidth: number = 0
  @State videoHeight: number = 0
  @State videoOffsetY: number = 0
  @State isPortrait: boolean = isPortrait()
  @State isFloatActionLayoutVisible: boolean = false
  private componentController: XComponentController = new XComponentController()
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_feed_video_background: string = createId()
  private readonly plv_media_player_feed_video_xcomponent: string = createId()
  private readonly plv_media_player_feed_video_controller_layout: string = createId()
  private readonly plv_media_player_feed_video_float_action_layout: string = createId()
  private readonly plv_media_player_handle_on_enter_background_component: string = createId()
  private readonly plv_media_player_play_complete_auto_restart_component: string = createId()
  private readonly plv_media_player_feed_video_state_handle_component: string = createId()
  private readonly plv_media_player_feed_video_layout_root: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    requireNotNull(this.mediaResource, () => 'mediaResource must not be null')
    requireNotNull(this.mediaResourceIndex, () => 'mediaResourceIndex must not be null')

    this.observeMediaViewState()
    this.observeOrientation()
    this.setupMediaPlayer()

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isFloatActionLayoutVisible = viewState.isFloatActionLayoutVisible()
      this.videoWidth = viewState.videoViewLocation.width
      this.videoHeight = viewState.videoViewLocation.height
      this.videoOffsetY = viewState.videoViewLocation.offset.y
    }).pushTo(this.observers)
  }

  private setupMediaPlayer() {
    this.viewModel.setAutoContinue(true)
    this.viewModel.setPlayerOption([
      PLVMediaPlayerOptionEnum.START_ON_PREPARED.value("0"),
      PLVMediaPlayerOptionEnum.RENDER_ON_PREPARED.value("1"),
      PLVMediaPlayerOptionEnum.ENABLE_ACCURATE_SEEK.value("1")
    ])
    this.viewModel.setMediaResource(this.mediaResource)
  }

  build() {
    RelativeContainer() {
      // 背景 横屏时使用黑色背景
      if (!this.isPortrait) {
        Shape()
          .id(this.plv_media_player_feed_video_background)
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
      }

      // 视频播放器
      XComponent({
        id: `plv_media_player_feed_video_xcomponent_${this.mediaResourceIndex}`,
        type: "surface",
        libraryname: "plvplayer_xcomponent",
        controller: this.componentController
      }) {
      }
      .id(this.plv_media_player_feed_video_xcomponent)
      .width(this.videoWidth)
      .height(this.videoHeight)
      .alignRules({
        center: toCenterOf(parent),
        middle: toMiddleOf(parent)
      })
      .offset({
        y: this.videoOffsetY
      })
      .onLoad((xcomponent) => {
        this.viewModel.setXComponent(xcomponent)
        this.viewModel.onScreenshot = async () => {
          return await this.getUIContext().getComponentSnapshot().get(this.plv_media_player_feed_video_xcomponent)
        }
      })

      // 播放控制皮肤
      PLVMediaPlayerFeedVideoControllerLayout()
        .id(this.plv_media_player_feed_video_controller_layout)
        .width('100%')
        .height('100%')

      // 更多功能弹层布局
      if (this.isFloatActionLayoutVisible) {
        PLVMediaPlayerFeedVideoFloatActionLayout()
          .id(this.plv_media_player_feed_video_float_action_layout)
          .width('100%')
          .height('100%')
          .gesture(
            // 消费滑动事件，禁止 feed 流滑动
            PanGesture({
              direction: PanDirection.All
            })
          )
      }

      // 进入后台播放处理逻辑
      PLVMediaPlayerHandleOnEnterBackgroundComponent()
        .id(this.plv_media_player_handle_on_enter_background_component)

      // 播放完成自动重新播放逻辑
      PLVMediaPlayerPlayCompleteAutoRestartComponent()
        .id(this.plv_media_player_play_complete_auto_restart_component)

      // 响应 Feed 流滑动时控制播放暂停处理逻辑
      PLVMediaPlayerFeedVideoStateHandleComponent({
        mediaResourceIndex: this.mediaResourceIndex
      })
        .id(this.plv_media_player_feed_video_state_handle_component)
    }
    .id(this.plv_media_player_feed_video_layout_root)
    .width('100%')
    .height('100%')
  }

  // <editor-fold defaultstate="collapsed" desc="UI - 更新播放器尺寸">

  private observeMediaViewState() {
    this.viewModel.mediaInfoViewState.observe(() => {
      this.updateVideoSize()
    }).pushTo(this.observers)
  }

  private observeOrientation() {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait) => {
      this.isPortrait = isPortrait
      this.updateVideoSize()
      // 只有横屏有操作锁定，竖屏没有
      if (isPortrait) {
        this.controllerViewModel.lockMediaController('unlock')
        this.controllerViewModel.changeControllerVisible(true);
      }
    }).pushTo(this.observers)
  }

  private updateVideoSize() {
    const viewState = this.viewModel.mediaInfoViewState.value
    if (!viewState || viewState.videoSize.width() === 0 || viewState.videoSize.height() === 0) {
      return
    }
    const containerWidth = getDisplayWindowWidth().vp
    const containerHeight = getDisplayWindowHeight().vp
    const containerRatio = containerWidth / containerHeight
    let videoWidth = containerWidth
    let videoHeight = containerHeight
    const videoRatio = viewState.videoSize.width() / viewState.videoSize.height()
    // fit center
    if (containerRatio > videoRatio) {
      videoWidth = containerHeight / viewState.videoSize.height() * viewState.videoSize.width()
    } else if (containerRatio < videoRatio) {
      videoHeight = containerWidth / viewState.videoSize.width() * viewState.videoSize.height()
    }
    this.controllerViewModel.updateVideoViewLocation({
      width: videoWidth,
      height: videoHeight,
      offset: {
        x: 0,
        y: this.isPortrait && videoRatio > 1 ? -40 : 0
      }
    })
  }

  // </editor-fold>

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
    this.dependScope.destroy()
  }
}
