import { safe, seconds } from '@polyvharmony/media-player-sdk';
import { promptAction } from '@kit.ArkUI';
import { PLVMediaPlayerSingleVideoPage } from './PLVMediaPlayerSingleVideoPage';
import { PLVMockMediaResourceData } from '../mock/PLVMockMediaResourceData';
import { PLVMediaPlayerFeedVideoPage } from './PLVMediaPlayerFeedVideoPage';
import {
  PLVMediaPlayerFeedVideoPageParam,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
  whatever
} from 'media-player-common';

@Entry
@Component
struct PLVMediaPlayerEntrancePage {
  @Provide navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack) {
      Stack() {
        Image($r('app.media.plv_media_player_video_item_background_portrait'))
          .objectFit(ImageFit.Cover)
          .expandSafeArea()

        Column({ space: 32 }) {
          FeedVideoEntry()
          SingleVideoEntry()
        }
      }
      .width('100%')
      .height('100%')
    }
    .id('plv_media_player_root_navigation')
    .hideTitleBar(true)
    .expandSafeArea()
    .mode(NavigationMode.Stack)
    .navDestination(this.navDestination)
  }

  @Builder
  private navDestination(name: string, param: whatever) {
    if (name === PLVMediaPlayerScenes.SINGLE_VIDEO.name) {
      PLVMediaPlayerSingleVideoPage()
    }
    if (name === PLVMediaPlayerScenes.FEED_VIDEO.name) {
      PLVMediaPlayerFeedVideoPage()
    }
  }
}

@Component
struct FeedVideoEntry {
  @Consume navPathStack: NavPathStack

  build() {
    Stack() {
      Image($r('app.media.plv_media_player_entrance_feed_video_bg'))
      Text($r('app.string.plv_media_player_entrance_feed_video_text'))
        .fontColor('#FFFFFF')
        .fontSize(24)
        .margin(20)
    }
    .alignContent(Alignment.TopStart)
    .width(212)
    .height(108)
    .onClick(async () => {
      const mediaResourcesResult = await safe(PLVMockMediaResourceData.getInstance().getMediaResources())
      if (mediaResourcesResult.success === false) {
        promptAction.showToast({
          message: `${$r('app.string.plv_media_player_fail_to_load_media_resource')}: ${mediaResourcesResult.error}`,
          duration: seconds(3).toMillis()
        })
        return
      }
      const mediaResources = mediaResourcesResult.data.slice(0, 5)
      this.navPathStack.pushPath(new NavPathInfo(
        PLVMediaPlayerScenes.FEED_VIDEO.name,
        new PLVMediaPlayerFeedVideoPageParam(mediaResources)
      ))
    })
  }
}

@Component
struct SingleVideoEntry {
  @Consume navPathStack: NavPathStack

  build() {
    Stack() {
      Image($r('app.media.plv_media_player_entrance_single_video_bg'))
      Text($r('app.string.plv_media_player_entrance_single_video_text'))
        .fontColor('#FFFFFF')
        .fontSize(24)
        .margin(20)
    }
    .alignContent(Alignment.TopStart)
    .width(212)
    .height(108)
    .onClick(async () => {
      const mediaResourcesResult = await safe(PLVMockMediaResourceData.getInstance().getMediaResources())
      if (mediaResourcesResult.success === false) {
        promptAction.showToast({
          message: `${$r('app.string.plv_media_player_fail_to_load_media_resource')}: ${mediaResourcesResult.error}`,
          duration: seconds(3).toMillis()
        })
        return
      }
      const mediaResource = mediaResourcesResult.data[0]
      this.navPathStack.pushPath(new NavPathInfo(
        PLVMediaPlayerScenes.SINGLE_VIDEO.name,
        new PLVMediaPlayerSingleVideoPageParam(mediaResource)
      ))
    })
  }
}
