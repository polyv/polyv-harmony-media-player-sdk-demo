import { logger, safe, seconds } from '@polyvharmony/media-player-sdk';
import { promptAction, router } from '@kit.ArkUI';
import { PLVMediaPlayerSingleVideoPageParam } from './PLVMediaPlayerSingleVideoPage';
import { PLVMockMediaResourceData } from '../mock/PLVMockMediaResourceData';

@Entry
@Component
struct PLVMediaPlayerEntrancePage {
  build() {
    Stack() {
      Image($r('app.media.plv_media_player_video_item_background_portrait'))
        .objectFit(ImageFit.Cover)
        .expandSafeArea()

      Column() {
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
          router.pushUrl({
            url: "pages/PLVMediaPlayerSingleVideoPage",
            params: new PLVMediaPlayerSingleVideoPageParam(mediaResource)
          }).catch((err: Error) => {
            logger.error("PLVMediaPlayerEntrancePage", "start single video ability error", err)
          })
        })
      }
    }
  }
}