import { PLVMediaPlayerSingleVideoLayout } from 'scene_single_video';
import {
  DependScope,
  Disposable,
  extendArray,
  lateInit,
  PLVMediaResource,
  randomInt,
  requireNotNull,
  runCatching
} from '@polyvharmony/media-player-sdk';
import {
  defineIds,
  PLVMediaPlayerSingleVideoPageParam,
  PLVMPPageControlViewModel,
  PLVOrientationManager,
  PLVOrientationManagerObserver
} from 'media-player-common';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import { PLVMockMediaResourceData } from '../mock/PLVMockMediaResourceData';

@Component
export struct PLVMediaPlayerSingleVideoPage {
  param: PLVMediaPlayerSingleVideoPageParam = lateInit()
  @Consume navPathStack: NavPathStack
  @Consume pageDependScope: DependScope
  private context = getContext(this) as common.UIAbilityContext
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private recommendVideos: PLVMediaResource[] = []
  private onBackPressDisposable: Disposable | undefined = undefined
  private readonly ids = defineIds(
    'plv_media_player_single_video_background'
  )

  aboutToAppear(): void {
    requireNotNull(this.param, () => "param is null")
    this.onBackPressDisposable = this.pageControlViewModel.onBackPressHandler.register(10, () => this.onBackPress())
    runCatching(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(true)
    })
    this.prepareRecommendVideos()
  }

  private async prepareRecommendVideos() {
    const mediaResources = await runCatching(PLVMockMediaResourceData.getInstance().getMediaResources())
    if (mediaResources.success === false) {
      return
    }
    this.recommendVideos = extendArray(mediaResources.data)
      .filter(it => it !== this.param.mediaResource)
      .sortBy_ext(() => randomInt(-1, 1))
      .sortBy_ext(() => randomInt(-1, 1))
      .sortBy_ext(() => randomInt(-1, 1))
      .slice(0, 10)
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.plv_media_player_video_item_background_portrait'))
        .id(this.ids.plv_media_player_single_video_background)
        .objectFit(ImageFit.Cover)
        .expandSafeArea(undefined, [SafeAreaEdge.BOTTOM])

      PLVMediaPlayerSingleVideoLayout({
        mediaResource: this.param.mediaResource,
        recommendVideos: this.recommendVideos,
        enterFromDownloadCenter: this.param.enterFromDownloadCenter
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