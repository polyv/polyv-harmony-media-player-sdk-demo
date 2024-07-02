import { PLVMediaPlayerSingleVideoLayout } from 'scene_single_video';
import { createDependScope, DependScope, requireNotNull, safe } from '@polyvharmony/media-player-sdk';
import {
  commonPageModule,
  createId,
  PLVAbilityContexts,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
  PLVMPPageControlViewModel,
  PLVOrientationManager,
  PLVOrientationManagerObserver
} from 'media-player-common';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';

@Component
export struct PLVMediaPlayerSingleVideoPage {
  @Consume navPathStack: NavPathStack
  private param: PLVMediaPlayerSingleVideoPageParam = this.navPathStack.getParamByName(PLVMediaPlayerScenes.SINGLE_VIDEO.name)[0] as PLVMediaPlayerSingleVideoPageParam
  private context = getContext(this) as common.UIAbilityContext
  @Provide pageDependScope: DependScope = createDependScope(commonPageModule)
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private readonly plv_media_player_single_video_background: string = createId()

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
          .id(this.plv_media_player_single_video_background)
          .objectFit(ImageFit.Cover)

        PLVMediaPlayerSingleVideoLayout({
          mediaResource: this.param.mediaResource,
        })

        // 屏幕方向监听器
        PLVOrientationManagerObserver()
      }
    }
    .hideTitleBar(true)
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