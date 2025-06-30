import {
  defineIds,
  PLVMediaPlayerFeedVideoPageParam,
  PLVMediaPlayerScenes,
  PLVMPPageControlViewModel,
  PLVOrientationManager,
  PLVOrientationManagerObserver
} from 'media-player-common';
import common from '@ohos.app.ability.common';
import {
  IPLVMediaPlayerFeedResourceDataSource,
  PLVMediaPlayerFeedSwiperDataSource,
  PLVMediaPlayerFeedVideoLayout
} from 'scene_feed_video';
import {
  DependScope,
  Disposable,
  getUniqueKey,
  PLVMediaResource,
  requireNotNull,
  runCatching
} from '@polyvharmony/media-player-sdk';
import { PLVMockFeedResourceDataSource } from '../mock/PLVMockFeedResourceDataSource';
import window from '@ohos.window';

@Component
export struct PLVMediaPlayerFeedVideoPage {
  @Consume navPathStack: NavPathStack
  @Consume pageDependScope: DependScope
  private param: PLVMediaPlayerFeedVideoPageParam = this.navPathStack.getParamByName(PLVMediaPlayerScenes.FEED_VIDEO.name)[0] as PLVMediaPlayerFeedVideoPageParam
  private context = getContext(this) as common.UIAbilityContext
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private feedDataSource: IPLVMediaPlayerFeedResourceDataSource = new PLVMockFeedResourceDataSource();
  private swiperDataSource: PLVMediaPlayerFeedSwiperDataSource = new PLVMediaPlayerFeedSwiperDataSource(this.feedDataSource, this.param.initialMediaSources)
  private onBackPressDisposable: Disposable | undefined = undefined
  private readonly ids = defineIds(
    'plv_media_player_feed_video_background'
  )

  aboutToAppear(): void {
    requireNotNull(this.param, () => "param is null")
    this.onBackPressDisposable = this.pageControlViewModel.onBackPressHandler.register(10, () => this.onBackPress())
    runCatching(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(true)
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.plv_media_player_video_item_background_portrait'))
        .id(this.ids.plv_media_player_feed_video_background)
        .objectFit(ImageFit.Cover)
        .expandSafeArea()

      // Feed 滑动列表容器
      Swiper() {
        LazyForEach(
          this.swiperDataSource,
          (item: PLVMediaResource, index: number) => {
            PLVMediaPlayerFeedVideoLayout({ mediaResource: item, mediaResourceIndex: index })
          },
          (item: PLVMediaResource) => getUniqueKey(item)
        )
      }
      .indicator(false)
      .autoPlay(false)
      .loop(false)
      .vertical(true)
      .onChange((index: number) => {
        this.pageControlViewModel.onCurrentItemChanged(index)
      })
      .onGestureSwipe((index: number, event: SwiperAnimationEvent) => {
        this.swiperDataSource.onGestureSwipe(index, event)
      })
      .onAnimationEnd((index: number, event: SwiperAnimationEvent) => {
        this.swiperDataSource.onAnimationEnd(index, event)
      })

      // 屏幕方向监听器
      PLVOrientationManagerObserver()
    }
  }

  onBackPress(): boolean {
    if (!PLVOrientationManager.getInstance().isPortrait.value) {
      PLVOrientationManager.getInstance().requestOrientation('port');
      return true;
    }
    return false;
  }

  aboutToDisappear(): void {
    this.onBackPressDisposable?.dispose()
    runCatching(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(false)
    })
  }
}