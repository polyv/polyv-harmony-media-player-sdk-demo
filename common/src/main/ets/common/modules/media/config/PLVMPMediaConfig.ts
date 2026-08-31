import { promptAction } from '@kit.ArkUI';
import {
  DefaultVodMediaTokenRequestListener,
  IPLVVodMediaTokenRequestListener,
  PLVMediaPlayerBusinessError,
  PLVMediaPlayerBusinessErrorEnum,
  PLVVodMainAccountAuthentication,
  PLVVodMediaResource,
  PLVVodVideoTokenVO
} from '@polyvharmony/media-player-sdk';

/**
 * 媒体播放全局配置类，用于外部（如 demo 代码）设置全局配置。
 */
export class PLVMPMediaConfig {
  /**
   * 是否使用自定义 Token 播放。
   * true：需要设置 vodTokenRequestListener，无需在认证信息中配置 secretKey。
   * false：使用默认认证方式，需要配置 secretKey。
   */
  static useCustomToken: boolean = false
}

const demoUserId = "e97dbe3e64"
const demoSecretKey = "zMV29c519P"

export const customTokenRequestListener: IPLVVodMediaTokenRequestListener = {
  async onRequestToken(mediaResource: PLVVodMediaResource): Promise<PLVVodVideoTokenVO> {
    const authentication = mediaResource.authentication as PLVVodMainAccountAuthentication
    if (authentication.userId === demoUserId) {
      return DefaultVodMediaTokenRequestListener.onRequestToken({
        ...mediaResource,
        authentication: {
          ...authentication,
          userId: demoUserId,
          secretKey: demoSecretKey
        }
      })
    }

    promptAction.showToast({
      message: "请参考 https://help.polyv.net/#/vod/harmony_player_sdk/4-加密视频版权保护 获取播放视频凭证",
      duration: 5000
    })
    // 接入方应在此处向自己的服务端请求播放 Token，并返回 PLVVodVideoTokenVO。
    throw new PLVMediaPlayerBusinessError(
      PLVMediaPlayerBusinessErrorEnum.ERROR_GET_VIDEO_TOKEN,
      "Custom video token is not configured"
    )
  }
}
