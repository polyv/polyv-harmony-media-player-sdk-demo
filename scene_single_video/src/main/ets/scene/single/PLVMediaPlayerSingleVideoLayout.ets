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
  PLVMPDownloadItemViewModel,
  PLVMPMediaControllerViewModel,
  PLVMPMediaViewModel,
  PLVOrientationManager,
  toCenterOf,
  toMiddleOf,
  toTopOf
} from 'media-player-common';
import { PLVMediaPlayerAuxiliaryLayout } from './component/PLVMediaPlayerAuxiliaryLayout';
import { PLVMediaPlayerSingleVideoControllerLayout } from './layout/PLVMediaPlayerSingleVideoControllerLayout';
import { PLVMediaPlayerSingleVideoFloatActionLayout } from './layout/PLVMediaPlayerSingleVideoFloatActionLayout';

@Preview
@Component
export struct PLVMediaPlayerSingleVideoLayout {
  mediaResource?: PLVMediaResource
  enterFromDownloadCenter: boolean = false
  @Provide dependScope: DependScope = createDependScope(commonItemModule)
  @Consume pageDependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel);
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel);
  private downloadItemViewModel: PLVMPDownloadItemViewModel = this.dependScope.get(PLVMPDownloadItemViewModel)
  @State videoWidth: number = 0
  @State videoHeight: number = 0
  @State isPortrait: boolean = isPortrait()
  @State isFloatActionLayoutVisible: boolean = false
  private componentController: XComponentController = new XComponentController()
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_single_video_xcomponent: string = createId()
  private readonly plv_media_player_single_video_controller_layout: string = createId()
  private readonly plv_media_player_single_video_container: string = createId()
  private readonly plv_media_player_single_video_float_action_layout: string = createId()
  private readonly plv_media_player_single_video_layout_root: string = createId()
  private readonly plv_media_player_handle_on_enter_background_component: string = createId()
  private readonly plv_media_player_auxiliary_layout: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    requireNotNull(this.mediaResource, () => 'mediaResource must not be null')
    this.observeMediaViewState()
    this.observeOrientation()
    this.downloadItemViewModel.setDownloadActionVisible(!this.enterFromDownloadCenter)
    this.setupMediaPlayer()
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isFloatActionLayoutVisible = viewState.isFloatActionLayoutVisible()
      this.videoWidth = viewState.videoViewLocation.width
      this.videoHeight = viewState.videoViewLocation.height
    }).pushTo(this.observers)
  }

  private setupMediaPlayer() {
    this.viewModel.setAutoContinue(true)
    this.viewModel.setPlayerOption([
      PLVMediaPlayerOptionEnum.ENABLE_ACCURATE_SEEK.value("1"),
      PLVMediaPlayerOptionEnum.SKIP_ACCURATE_SEEK_AT_START.value("1"),
    ])
    this.viewModel.setMediaResource(this.mediaResource)
  }

  build() {
    RelativeContainer() {
      RelativeContainer() {
        // 视频播放器
        XComponent({
          id: `plv_media_player_single_video_xcomponent`,
          type: "surface",
          libraryname: "plvplayer_xcomponent",
          controller: this.componentController
        }) {
        }
        .id(this.plv_media_player_single_video_xcomponent)
        .width(this.videoWidth)
        .height(this.videoHeight)
        .alignRules({
          center: toCenterOf(parent),
          middle: toMiddleOf(parent)
        })
        .onLoad((xcomponent) => {
          this.viewModel.setXComponent(xcomponent)
          this.viewModel.onScreenshot = async () => {
            return await this.getUIContext().getComponentSnapshot().get(this.plv_media_player_single_video_xcomponent)
          }
        })

        // 播放控制皮肤
        PLVMediaPlayerSingleVideoControllerLayout()
          .id(this.plv_media_player_single_video_controller_layout)
          .width('100%')
          .height('100%')
          .alignRules({
            center: toCenterOf(parent),
            middle: toMiddleOf(parent)
          })
      }
      .id(this.plv_media_player_single_video_container)
      .width('100%')
      .height(this.videoContainerHeight())
      .alignRules({
        top: toTopOf(parent)
      })
      .backgroundColor('#000000')

      // 更多功能弹层布局
      if (this.isFloatActionLayoutVisible) {
        PLVMediaPlayerSingleVideoFloatActionLayout()
          .id(this.plv_media_player_single_video_float_action_layout)
          .width('100%')
          .height('100%')
      }

      // 进入后台播放处理逻辑
      PLVMediaPlayerHandleOnEnterBackgroundComponent()
        .id(this.plv_media_player_handle_on_enter_background_component)
        .visibility(Visibility.None)

      // 广告播放器布局
      PLVMediaPlayerAuxiliaryLayout()
        .id(this.plv_media_player_auxiliary_layout)

    }
    .id(this.plv_media_player_single_video_layout_root)
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
      }
    }).pushTo(this.observers)
  }

  private updateVideoSize() {
    const viewState = this.viewModel.mediaInfoViewState.value
    if (!viewState) {
      return
    }
    const containerWidth = getDisplayWindowWidth().vp
    const containerHeight = this.isPortrait ? containerWidth / 16 * 9 : getDisplayWindowHeight().vp
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
        y: 0
      }
    })
  }

  private videoContainerHeight() {
    if (this.isPortrait) {
      return getDisplayWindowWidth().vp / 16 * 9
    } else {
      return '100%'
    }
  }

  // </editor-fold>

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
    this.dependScope.destroy()
  }
}
