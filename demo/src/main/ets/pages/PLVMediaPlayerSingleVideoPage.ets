import { PLVMediaPlayerSingleVideoLayout } from 'scene_single_video';
import { PLVMediaResource, safe } from '@polyvharmony/media-player-sdk';
import router from '@ohos.router';
import {
  createId,
  PLVAbilityContexts,
  PLVComponentLifecycle,
  PLVOrientationManager,
  PLVOrientationManagerObserver
} from 'media-player-common';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';

export class PLVMediaPlayerSingleVideoPageParam {
  readonly mediaResource: PLVMediaResource

  constructor(mediaResource: PLVMediaResource) {
    this.mediaResource = mediaResource
  }
}

@Entry
@Component
struct PLVMediaPlayerSingleVideoPage {
  private param: PLVMediaPlayerSingleVideoPageParam = router.getParams() as PLVMediaPlayerSingleVideoPageParam
  private context = getContext(this) as common.UIAbilityContext
  @Provide pageLifecycle: PLVComponentLifecycle = new PLVComponentLifecycle()
  private readonly plv_media_player_single_video_background: string = createId()

  aboutToAppear(): void {
    PLVAbilityContexts.getInstance().registerContext(getContext(this) as common.UIAbilityContext)
    this.pageLifecycle.onAboutToAppear()
  }

  onPageShow(): void {
    this.pageLifecycle.onPageShow()
    safe(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(true)
    })
  }

  build() {
    Stack() {
      // 背景图
      Image($r('app.media.plv_media_player_video_item_background_portrait'))
        .id(this.plv_media_player_single_video_background)
        .objectFit(ImageFit.Cover)

      PLVMediaPlayerSingleVideoLayout({ mediaResource: this.param.mediaResource })

      // 屏幕方向监听器
      PLVOrientationManagerObserver()
    }
  }

  onBackPress(): boolean | void {
    if (!PLVOrientationManager.getInstance().isPortrait.value) {
      PLVOrientationManager.getInstance().requestOrientation('port');
      return true;
    }
  }

  onPageHide(): void {
    safe(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(false)
    })
    this.pageLifecycle.onPageHide()
  }

  aboutToDisappear(): void {
    this.pageLifecycle.onAboutToDisappear()
    PLVAbilityContexts.getInstance().unregisterContext(getContext(this) as common.UIAbilityContext)
  }
}