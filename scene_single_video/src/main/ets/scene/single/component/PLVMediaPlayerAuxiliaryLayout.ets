import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  defineIds,
  getDisplayWindowHeight,
  getDisplayWindowWidth,
  isPortrait,
  parent,
  PLVMediaPlayerAuxiliaryCountDownTextView,
  PLVMPAuxiliaryViewModel,
  PLVOrientationManager,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toTopOf
} from 'media-player-common'

@Component
export struct PLVMediaPlayerAuxiliaryLayout {
  @Consume dependScope: DependScope
  private auxiliaryViewModel: PLVMPAuxiliaryViewModel = this.dependScope.get(PLVMPAuxiliaryViewModel)
  @State isVisible: boolean = false
  @State isImage: boolean = false
  @State imageUrl: string = ""
  @State videoWidth: number = 0
  @State videoHeight: number = 0
  @State isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_auxiliary_advert_image',
    'plv_media_player_auxiliary_advert_video_xcomponent',
    'plv_media_player_auxiliary_count_down_text_view'
  )

  aboutToAppear(): void {
    this.auxiliaryViewModel.bind()

    this.observeMediaViewState()
    this.observeOrientation()

    this.auxiliaryViewModel.auxiliaryInfoViewState.observe((viewState) => {
      this.isVisible = viewState !== null
      if (viewState === null) {
        return
      }
      this.isImage = viewState.isImage
      this.imageUrl = viewState.url
    }).pushTo(this.observers)

  }

  build() {
    RelativeContainer() {
      // 视频播放器
      XComponent({
        id: `plv_media_player_auxiliary_video_xcomponent`,
        type: "surface",
        libraryname: "plvplayer_xcomponent"
      }) {
      }
      .id(this.ids.plv_media_player_auxiliary_advert_video_xcomponent)
      .width(this.videoWidth)
      .height(this.videoHeight)
      .alignRules({
        center: toCenterOf(parent),
        middle: toMiddleOf(parent)
      })
      .onLoad((xComponent) => {
        this.auxiliaryViewModel.setXComponent(xComponent)
      })

      // 图片类型广告
      if (this.isImage) {
        Image(this.imageUrl)
          .id(this.ids.plv_media_player_auxiliary_advert_image)
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .objectFit(ImageFit.Contain)
          .alignRules({
            center: toCenterOf(parent),
            middle: toMiddleOf(parent)
          })
      }

      // 广告倒计时
      PLVMediaPlayerAuxiliaryCountDownTextView()
        .id(this.ids.plv_media_player_auxiliary_count_down_text_view)
        .alignRules({
          right: toEndOf(parent),
          top: toTopOf(parent)
        })

    }
    .backgroundColor('#000000')
    .width('100%')
    .height(this.videoContainerHeight())
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  // <editor-fold defaultstate="collapsed" desc="UI - 更新播放器尺寸">

  private observeMediaViewState() {
    this.auxiliaryViewModel.auxiliaryVideoInfoViewState.observe(() => {
      this.updateVideoSize()
    }).pushTo(this.observers)
  }

  private observeOrientation() {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait) => {
      this.isPortrait = isPortrait
      this.updateVideoSize()
    }).pushTo(this.observers)
  }

  private updateVideoSize() {
    const viewState = this.auxiliaryViewModel.auxiliaryVideoInfoViewState.value
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
    this.videoWidth = videoWidth
    this.videoHeight = videoHeight
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
    this.auxiliaryViewModel.unbind()
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}