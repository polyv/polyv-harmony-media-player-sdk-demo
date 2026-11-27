import { promptAction } from '@kit.ArkUI';
import { normalizeSeekStep } from '../../mediacontroller/model/PLVMPStepSeek';
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

  /** 是否使用中央快进退布局，默认关闭。在创建播放器前配置。 */
  static seekButtonsEnabled: boolean = false

  private static _seekStepSeconds: number = 15

  /** 快进退步长，初始化播放器前设置；5–60 整数秒，非法值回落到 15。 */
  static get seekStepSeconds(): number {
    return PLVMPMediaConfig._seekStepSeconds
  }

  static set seekStepSeconds(seconds: number) {
    PLVMPMediaConfig._seekStepSeconds = normalizeSeekStep(seconds)
  }
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
