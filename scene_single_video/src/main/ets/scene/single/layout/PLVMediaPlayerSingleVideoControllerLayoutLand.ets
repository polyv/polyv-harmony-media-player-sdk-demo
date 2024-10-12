import { createDependScope, DependScope } from '@polyvharmony/media-player-sdk'
import {
  commonItemModule,
  createId,
  parent,
  PLVMediaPlayerAudioModeCoverLayoutLand,
  PLVMediaPlayerAutoContinueHintLayout,
  PLVMediaPlayerBackImageView,
  PLVMediaPlayerBitRateTextView,
  PLVMediaPlayerBrightnessVolumeUpdateHintLayout,
  PLVMediaPlayerBufferingSpeedLayout,
  PLVMediaPlayerControllerGradientMaskLayout,
  PLVMediaPlayerGestureHandleLayout,
  PLVMediaPlayerLockControllerImageView,
  PLVMediaPlayerLongPressSpeedHintLayout,
  PLVMediaPlayerMarqueeLayout,
  PLVMediaPlayerMoreActionImageView,
  PLVMediaPlayerNetworkPoorIndicateLayout,
  PLVMediaPlayerPlayButton,
  PLVMediaPlayerPlayCompleteManualRestartOverlayLayout,
  PLVMediaPlayerPlayErrorOverlayLayout,
  PLVMediaPlayerProgressTextView,
  PLVMediaPlayerScreenshotImageView,
  PLVMediaPlayerSeekProgressPreviewLayout,
  PLVMediaPlayerSpeedTextView,
  PLVMediaPlayerSubtitleTextLayout,
  PLVMediaPlayerSwitchBitRateHintLayout,
  PLVMediaPlayerTitleTextView,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf,
  usePadding
} from 'media-player-common'
import { PLVMediaPlayerProgressSliderSingleLand } from '../component/PLVMediaPlayerProgressSliderSingleLand'

@Component
export struct PLVMediaPlayerSingleVideoControllerLayoutLand {
  @Consume dependScope: DependScope
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_subtitle_text_layout: string = createId()
  private readonly plv_media_player_controller_gradient_mask_layout: string = createId()
  private readonly plv_media_player_gesture_handle_layout: string = createId()
  private readonly plv_media_player_marquee_layout: string = createId()
  private readonly plv_media_player_audio_mode_cover_layout: string = createId()
  private readonly plv_media_player_buffering_speed_layout: string = createId()
  private readonly plv_media_player_complete_overlay_layout: string = createId()
  private readonly plv_media_player_error_overlay_layout: string = createId()
  private readonly plv_media_player_back_iv: string = createId()
  private readonly plv_media_player_title_tv: string = createId()
  private readonly plv_media_player_more_action_iv: string = createId()
  private readonly plv_media_player_play_button: string = createId()
  private readonly plv_media_player_progress_text_view: string = createId()
  private readonly plv_media_player_progress_slider: string = createId()
  private readonly plv_media_player_bit_rate_text_view: string = createId()
  private readonly plv_media_player_speed_text_view: string = createId()
  private readonly plv_media_player_lock_controller_iv: string = createId()
  private readonly plv_media_player_network_poor_indicate_layout: string = createId()
  private readonly plv_media_player_long_press_speed_hint_layout: string = createId()
  private readonly plv_media_player_auto_continue_hint_layout: string = createId()
  private readonly plv_media_player_switch_bit_rate_hint_layout: string = createId()
  private readonly plv_media_player_brightness_update_hint_layout: string = createId()
  private readonly plv_media_player_seek_progress_preview_layout: string = createId()
  private readonly plv_media_player_screenshot_iv: string = createId()

  // </editor-fold>

  build() {
    RelativeContainer() {
      // 字幕
      PLVMediaPlayerSubtitleTextLayout()
        .id(this.plv_media_player_subtitle_text_layout)
        .hitTestBehavior(HitTestMode.None)
        .margin({
          bottom: 34
        })
        .alignRules({
          bottom: toBottomOf(parent),
          middle: toMiddleOf(parent)
        })

      // 皮肤控件底部渐变遮罩蒙层
      PLVMediaPlayerControllerGradientMaskLayout()
        .id(this.plv_media_player_controller_gradient_mask_layout)
        .hitTestBehavior(HitTestMode.None)

      // 手势处理
      PLVMediaPlayerGestureHandleLayout()
        .id(this.plv_media_player_gesture_handle_layout)

      // 播放器跑马灯
      PLVMediaPlayerMarqueeLayout()
        .id(this.plv_media_player_marquee_layout)
        .hitTestBehavior(HitTestMode.None)

      // 音频模式
      PLVMediaPlayerAudioModeCoverLayoutLand()
        .id(this.plv_media_player_audio_mode_cover_layout)
        .hitTestBehavior(HitTestMode.Transparent)

      // 缓冲加载速度显示
      PLVMediaPlayerBufferingSpeedLayout()
        .id(this.plv_media_player_buffering_speed_layout)
        .hitTestBehavior(HitTestMode.None)

      // 播放结束覆盖层
      PLVMediaPlayerPlayCompleteManualRestartOverlayLayout()
        .id(this.plv_media_player_complete_overlay_layout)

      // 播放异常覆盖层
      PLVMediaPlayerPlayErrorOverlayLayout()
        .id(this.plv_media_player_error_overlay_layout)

      // 返回按钮
      PLVMediaPlayerBackImageView()
        .id(this.plv_media_player_back_iv)
        .width(28)
        .height(28)
        .margin(usePadding({
          left: 16,
          vertical: 24,
        }))
        .alignRules({
          left: toStartOf(parent),
          top: toTopOf(parent)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 视频标题
      PLVMediaPlayerTitleTextView()
        .id(this.plv_media_player_title_tv)
        .alignRules({
          center: toCenterOf(this.plv_media_player_back_iv),
          left: toEndOf(this.plv_media_player_back_iv),
          right: toStartOf(this.plv_media_player_more_action_iv)
        })
        .hitTestBehavior(HitTestMode.None)

      // 更多按钮
      PLVMediaPlayerMoreActionImageView()
        .id(this.plv_media_player_more_action_iv)
        .width(28)
        .height(28)
        .alignRules({
          top: toTopOf(parent),
          right: toEndOf(parent),
        })
        .margin({
          top: 24,
          right: 16
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放/暂停按钮
      PLVMediaPlayerPlayButton()
        .id(this.plv_media_player_play_button)
        .width(24)
        .height(24)
        .margin(usePadding({
          left: 16,
          vertical: 28
        }))
        .alignRules({
          left: toStartOf(parent),
          bottom: toBottomOf(parent)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放进度文本
      PLVMediaPlayerProgressTextView()
        .id(this.plv_media_player_progress_text_view)
        .alignRules({
          left: toEndOf(this.plv_media_player_play_button),
          center: toCenterOf(this.plv_media_player_play_button)
        })
        .margin({
          left: 9
        })
        .hitTestBehavior(HitTestMode.None)

      // 播放进度条
      PLVMediaPlayerProgressSliderSingleLand()
        .id(this.plv_media_player_progress_slider)
        .width('100%')
        .height(14)
        .padding(usePadding({
          horizontal: 12
        }))
        .margin({
          bottom: 6
        })
        .alignRules({
          bottom: toTopOf(this.plv_media_player_play_button)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 清晰度
      PLVMediaPlayerBitRateTextView()
        .id(this.plv_media_player_bit_rate_text_view)
        .alignRules({
          right: toEndOf(parent),
          bottom: toBottomOf(parent)
        })
        .margin({
          right: 16,
          bottom: 30
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 倍速
      PLVMediaPlayerSpeedTextView()
        .id(this.plv_media_player_speed_text_view)
        .alignRules({
          right: toStartOf(this.plv_media_player_bit_rate_text_view),
          bottom: toBottomOf(parent)
        })
        .margin({
          right: 24,
          bottom: 30
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 横屏操作锁定按钮
      PLVMediaPlayerLockControllerImageView()
        .id(this.plv_media_player_lock_controller_iv)
        .alignRules({
          left: toStartOf(parent),
          center: toCenterOf(parent)
        })
        .margin({
          left: 16
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 视频截图按钮
      PLVMediaPlayerScreenshotImageView()
        .id(this.plv_media_player_screenshot_iv)
        .alignRules({
          center: toCenterOf(parent),
          end: toEndOf(parent)
        })
        .margin({
          right: 16
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 弱网提示
      PLVMediaPlayerNetworkPoorIndicateLayout()
        .id(this.plv_media_player_network_poor_indicate_layout)
        .alignRules({
          right: toEndOf(parent),
          bottom: toTopOf(this.plv_media_player_bit_rate_text_view)
        })
        .margin({
          right: 15,
          bottom: 12
        })

      // 长按快进控制提示
      PLVMediaPlayerLongPressSpeedHintLayout()
        .id(this.plv_media_player_long_press_speed_hint_layout)
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })
        .margin({
          top: 28
        })

      // 自动续播提示条
      PLVMediaPlayerAutoContinueHintLayout()
        .id(this.plv_media_player_auto_continue_hint_layout)
        .alignRules({
          left: toStartOf(parent),
          bottom: toTopOf(this.plv_media_player_progress_slider)
        })
        .margin({
          left: 12,
          bottom: 12
        })

      // 切换清晰度提示条
      PLVMediaPlayerSwitchBitRateHintLayout()
        .id(this.plv_media_player_switch_bit_rate_hint_layout)
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })
        .margin({
          top: 28
        })

      // 亮度/音量 调节提示
      PLVMediaPlayerBrightnessVolumeUpdateHintLayout()
        .id(this.plv_media_player_brightness_update_hint_layout)
        .margin({
          top: 28
        })
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })

      // 拖动进度条时进度预览
      PLVMediaPlayerSeekProgressPreviewLayout()
        .id(this.plv_media_player_seek_progress_preview_layout)
        .margin({
          bottom: 8
        })
        .alignRules({
          bottom: toTopOf(this.plv_media_player_progress_slider),
          middle: toMiddleOf(parent)
        })

    }
  }
}


@Preview
@Component
struct PLVMediaPlayerSingleVideoControllerLayoutLandPreview {
  @Provide dependScope: DependScope = createDependScope(commonItemModule)

  build() {
    PLVMediaPlayerSingleVideoControllerLayoutLand()
  }
}