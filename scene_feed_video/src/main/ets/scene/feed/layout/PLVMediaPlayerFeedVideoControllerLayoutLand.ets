import { createDependScope, DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  commonItemModule,
  defineIds,
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
  PLVMPMediaControllerViewModel,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf,
  usePadding
} from 'media-player-common'
import { PLVMediaPlayerProgressSliderFeedLand } from '../component/PLVMediaPlayerProgressSliderFeedLand'

@Component
export struct PLVMediaPlayerFeedVideoControllerLayoutLand {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel);
  @State videoWidth: number = 0
  @State videoHeight: number = 0
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_feed_video_shadow',
    'plv_media_player_subtitle_text_layout',
    'plv_media_player_controller_gradient_mask_layout',
    'plv_media_player_gesture_handle_layout',
    'plv_media_player_marquee_layout',
    'plv_media_player_audio_mode_cover_layout',
    'plv_media_player_buffering_speed_layout',
    'plv_media_player_complete_overlay_layout',
    'plv_media_player_error_overlay_layout',
    'plv_media_player_back_iv',
    'plv_media_player_title_tv',
    'plv_media_player_more_action_iv',
    'plv_media_player_play_button',
    'plv_media_player_progress_text_view',
    'plv_media_player_progress_slider',
    'plv_media_player_bit_rate_text_view',
    'plv_media_player_speed_text_view',
    'plv_media_player_lock_controller_iv',
    'plv_media_player_network_poor_indicate_layout',
    'plv_media_player_long_press_speed_hint_layout',
    'plv_media_player_auto_continue_hint_layout',
    'plv_media_player_switch_bit_rate_hint_layout',
    'plv_media_player_brightness_update_hint_layout',
    'plv_media_player_seek_progress_preview_layout',
    'plv_media_player_screenshot_iv'
  )

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.videoWidth = viewState.videoViewLocation.width
      this.videoHeight = viewState.videoViewLocation.height
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      // 视频播放器视图位置在皮肤上的映射
      Shape()
        .id(this.ids.plv_media_player_feed_video_shadow)
        .width(this.videoWidth)
        .height(this.videoHeight)
        .alignRules({
          center: toCenterOf(parent),
          middle: toMiddleOf(parent)
        })
        .hitTestBehavior(HitTestMode.None)

      // 字幕
      PLVMediaPlayerSubtitleTextLayout()
        .id(this.ids.plv_media_player_subtitle_text_layout)
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
        .id(this.ids.plv_media_player_controller_gradient_mask_layout)
        .hitTestBehavior(HitTestMode.None)

      // 播放器跑马灯
      PLVMediaPlayerMarqueeLayout()
        .id(this.ids.plv_media_player_marquee_layout)
        .hitTestBehavior(HitTestMode.None)

      // 手势处理
      PLVMediaPlayerGestureHandleLayout()
        .id(this.ids.plv_media_player_gesture_handle_layout)

      // 音频模式
      PLVMediaPlayerAudioModeCoverLayoutLand()
        .id(this.ids.plv_media_player_audio_mode_cover_layout)
        .hitTestBehavior(HitTestMode.Transparent)

      // 缓冲加载速度显示
      PLVMediaPlayerBufferingSpeedLayout()
        .id(this.ids.plv_media_player_buffering_speed_layout)
        .hitTestBehavior(HitTestMode.None)

      // 播放结束覆盖层
      PLVMediaPlayerPlayCompleteManualRestartOverlayLayout()
        .id(this.ids.plv_media_player_complete_overlay_layout)

      // 播放异常覆盖层
      PLVMediaPlayerPlayErrorOverlayLayout()
        .id(this.ids.plv_media_player_error_overlay_layout)

      // 返回按钮
      PLVMediaPlayerBackImageView()
        .id(this.ids.plv_media_player_back_iv)
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
        .id(this.ids.plv_media_player_title_tv)
        .alignRules({
          center: toCenterOf(this.ids.plv_media_player_back_iv),
          left: toEndOf(this.ids.plv_media_player_back_iv),
          right: toStartOf(this.ids.plv_media_player_more_action_iv)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 更多按钮
      PLVMediaPlayerMoreActionImageView()
        .id(this.ids.plv_media_player_more_action_iv)
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
        .id(this.ids.plv_media_player_play_button)
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
        .id(this.ids.plv_media_player_progress_text_view)
        .alignRules({
          left: toEndOf(this.ids.plv_media_player_play_button),
          center: toCenterOf(this.ids.plv_media_player_play_button)
        })
        .margin({
          left: 9
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放进度条
      PLVMediaPlayerProgressSliderFeedLand()
        .id(this.ids.plv_media_player_progress_slider)
        .width('100%')
        .height(14)
        .padding(usePadding({
          horizontal: 12
        }))
        .margin({
          bottom: 6
        })
        .alignRules({
          bottom: toTopOf(this.ids.plv_media_player_play_button)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 清晰度
      PLVMediaPlayerBitRateTextView()
        .id(this.ids.plv_media_player_bit_rate_text_view)
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
        .id(this.ids.plv_media_player_speed_text_view)
        .alignRules({
          right: toStartOf(this.ids.plv_media_player_bit_rate_text_view),
          bottom: toBottomOf(parent)
        })
        .margin({
          right: 24,
          bottom: 30
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 横屏操作锁定按钮
      PLVMediaPlayerLockControllerImageView()
        .id(this.ids.plv_media_player_lock_controller_iv)
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
        .id(this.ids.plv_media_player_screenshot_iv)
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
        .id(this.ids.plv_media_player_network_poor_indicate_layout)
        .alignRules({
          right: toEndOf(parent),
          bottom: toTopOf(this.ids.plv_media_player_bit_rate_text_view)
        })
        .margin({
          right: 15,
          bottom: 12
        })

      // 长按快进控制提示
      PLVMediaPlayerLongPressSpeedHintLayout()
        .id(this.ids.plv_media_player_long_press_speed_hint_layout)
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })
        .margin({
          top: 28
        })

      // 自动续播提示条
      PLVMediaPlayerAutoContinueHintLayout()
        .id(this.ids.plv_media_player_auto_continue_hint_layout)
        .alignRules({
          left: toStartOf(parent),
          bottom: toTopOf(this.ids.plv_media_player_progress_slider)
        })
        .margin({
          left: 12,
          bottom: 12
        })

      // 切换清晰度提示条
      PLVMediaPlayerSwitchBitRateHintLayout()
        .id(this.ids.plv_media_player_switch_bit_rate_hint_layout)
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })
        .margin({
          top: 28
        })

      // 亮度/音量 调节提示
      PLVMediaPlayerBrightnessVolumeUpdateHintLayout()
        .id(this.ids.plv_media_player_brightness_update_hint_layout)
        .margin({
          top: 28
        })
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })

      // 拖动进度条时进度预览
      PLVMediaPlayerSeekProgressPreviewLayout()
        .id(this.ids.plv_media_player_seek_progress_preview_layout)
        .margin({
          bottom: 8
        })
        .alignRules({
          bottom: toTopOf(this.ids.plv_media_player_progress_slider),
          middle: toMiddleOf(parent)
        })

    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}


@Preview
@Component
struct PLVMediaPlayerSingleVideoControllerLayoutLandPreview {
  @Provide dependScope: DependScope = createDependScope(commonItemModule)

  build() {
    PLVMediaPlayerFeedVideoControllerLayoutLand()
  }
}