import { PLVMediaPlayerSingleVideoLayout } from 'scene_single_video';
import { requireNotNull, safe } from '@polyvharmony/media-player-sdk';
import {
  createId,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
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
  private readonly plv_media_player_single_video_background: string = createId()

  aboutToAppear(): void {
    requireNotNull(this.param, () => "param is null")

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
        .expandSafeArea(undefined, [SafeAreaEdge.BOTTOM])

      PLVMediaPlayerSingleVideoLayout({
        mediaResource: this.param.mediaResource,
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
    safe(async () => {
      const windowInstance = await window.getLastWindow(this.context)
      windowInstance.setWindowKeepScreenOn(false)
    })
  }
}