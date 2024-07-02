import {
  commonPageModule,
  createId,
  PLVAbilityContexts,
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
  createDependScope,
  DependScope,
  getUniqueKey,
  PLVMediaResource,
  requireNotNull,
  safe
} from '@polyvharmony/media-player-sdk';
import { PLVMockFeedResourceDataSource } from '../mock/PLVMockFeedResourceDataSource';
import window from '@ohos.window';

@Component
export struct PLVMediaPlayerFeedVideoPage {
  @Consume navPathStack: NavPathStack
  private param: PLVMediaPlayerFeedVideoPageParam = this.navPathStack.getParamByName(PLVMediaPlayerScenes.FEED_VIDEO.name)[0] as PLVMediaPlayerFeedVideoPageParam
  private context = getContext(this) as common.UIAbilityContext
  @Provide pageDependScope: DependScope = createDependScope(commonPageModule)
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private feedDataSource: IPLVMediaPlayerFeedResourceDataSource = new PLVMockFeedResourceDataSource();
  private swiperDataSource: PLVMediaPlayerFeedSwiperDataSource = new PLVMediaPlayerFeedSwiperDataSource(this.feedDataSource, this.param.initialMediaSources)
  private readonly plv_media_player_feed_video_background: string = createId()

  navAboutToAppear(): void {
    requireNotNull(this.param, () => "param is null")
    PLVAbilityContexts.getInstance().registerContext(getContext(this) as common.UIAbilityContext)
    this.pageControlViewModel.navPathStack = this.navPathStack
    this.pageControlViewModel.pageLifecycle.onAboutToAppear()

    safe(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(true)
    })
  }

  navOnPageShow(): void {
    this.pageControlViewModel.pageLifecycle.onPageShow()
  }

  build() {
    NavDestination() {
      Stack() {
        // 背景图
        Image($r('app.media.plv_media_player_video_item_background_portrait'))
          .id(this.plv_media_player_feed_video_background)
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
    .hideTitleBar(true)
    .expandSafeArea()
    .onAppear(() => this.navAboutToAppear())
    .onShown(() => this.navOnPageShow())
    .onBackPressed(() => this.navOnBackPress())
    .onHidden(() => this.navOnPageHide())
    .onDisAppear(() => this.navAboutToDisappear())
  }

  navOnBackPress(): boolean {
    if (!PLVOrientationManager.getInstance().isPortrait.value) {
      PLVOrientationManager.getInstance().requestOrientation('port');
      return true;
    }
    return false;
  }

  navOnPageHide(): void {
    this.pageControlViewModel.pageLifecycle.onPageHide()
  }

  navAboutToDisappear(): void {
    this.pageControlViewModel.pageLifecycle.onAboutToDisappear()
    PLVAbilityContexts.getInstance().unregisterContext(getContext(this) as common.UIAbilityContext)

    safe(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(false)
    })
  }
}