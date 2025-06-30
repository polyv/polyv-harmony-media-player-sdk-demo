import { createDependScope, DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  commonItemModule,
  defineIds,
  parent,
  PLVMediaPlayerAudioModeCoverLayoutPort,
  PLVMediaPlayerAutoContinueHintLayout,
  PLVMediaPlayerBackImageView,
  PLVMediaPlayerBufferingSpeedLayout,
  PLVMediaPlayerLongPressSpeedHintLayout,
  PLVMediaPlayerMarqueeLayout,
  PLVMediaPlayerMoreActionImageView,
  PLVMediaPlayerNetworkPoorIndicateLayout,
  PLVMediaPlayerPlayErrorOverlayLayout,
  PLVMediaPlayerProgressTextView,
  PLVMediaPlayerSeekProgressPreviewLayout,
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
import { PLVMediaPlayerGestureHandleLayoutFeedPort } from '../component/PLVMediaPlayerGestureHandleLayoutFeedPort'
import { PLVMediaPlayerPlayButtonFeedPort } from '../component/PLVMediaPlayerPlayButtonFeedPort'
import { PLVMediaPlayerProgressSliderFeedPort } from '../component/PLVMediaPlayerProgressSliderFeedPort'
import {
  PLVMediaPlayerSwitchToFullScreenButtonFeedPort
} from '../component/PLVMediaPlayerSwitchToFullScreenButtonFeedPort'

@Component
export struct PLVMediaPlayerFeedVideoControllerLayoutPort {
  @Consume dependScope: DependScope
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel);
  @State videoWidth: number = 0
  @State videoHeight: number = 0
  @State videoOffsetY: number = 0
  private observers: MutableObserver[] = []
  private readonly ids = defineIds(
    'plv_media_player_feed_video_shadow',
    'plv_media_player_subtitle_text_layout',
    'plv_media_player_gesture_handle_layout',
    'plv_media_player_marquee_layout',
    'plv_media_player_audio_mode_cover_layout',
    'plv_media_player_buffering_speed_layout',
    'plv_media_player_error_overlay_layout',
    'plv_media_player_back_iv',
    'plv_media_player_title_tv',
    'plv_media_player_more_action_iv',
    'plv_media_player_play_button',
    'plv_media_player_progress_text_view',
    'plv_media_player_switch_full_screen_btn',
    'plv_media_player_progress_slider',
    'plv_media_player_network_poor_indicate_layout',
    'plv_media_player_long_press_speed_hint_layout',
    'plv_media_player_auto_continue_hint_layout',
    'plv_media_player_switch_bit_rate_hint_layout',
    'plv_media_player_seek_progress_preview_layout'
  )

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.videoWidth = viewState.videoViewLocation.width
      this.videoHeight = viewState.videoViewLocation.height
      this.videoOffsetY = viewState.videoViewLocation.offset.y
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
        .offset({
          y: this.videoOffsetY
        })
        .hitTestBehavior(HitTestMode.None)

      // 字幕
      PLVMediaPlayerSubtitleTextLayout()
        .id(this.ids.plv_media_player_subtitle_text_layout)
        .hitTestBehavior(HitTestMode.None)
        .margin({
          bottom: 12
        })
        .offset({
          y: this.videoOffsetY
        })
        .alignRules({
          bottom: toBottomOf(this.ids.plv_media_player_feed_video_shadow),
          middle: toMiddleOf(parent)
        })

      // 手势处理
      PLVMediaPlayerGestureHandleLayoutFeedPort()
        .id(this.ids.plv_media_player_gesture_handle_layout)

      // 播放器跑马灯
      PLVMediaPlayerMarqueeLayout()
        .id(this.ids.plv_media_player_marquee_layout)
        .hitTestBehavior(HitTestMode.None)

      // 音频模式
      PLVMediaPlayerAudioModeCoverLayoutPort()
        .id(this.ids.plv_media_player_audio_mode_cover_layout)
        .alignRules({
          top: toTopOf(this.ids.plv_media_player_feed_video_shadow),
          bottom: toBottomOf(this.ids.plv_media_player_feed_video_shadow)
        })
        .offset({
          y: this.videoOffsetY
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 缓冲加载速度显示
      PLVMediaPlayerBufferingSpeedLayout()
        .id(this.ids.plv_media_player_buffering_speed_layout)
        .alignRules({
          top: toTopOf(this.ids.plv_media_player_feed_video_shadow),
          bottom: toBottomOf(this.ids.plv_media_player_feed_video_shadow)
        })
        .offset({
          y: this.videoOffsetY
        })
        .hitTestBehavior(HitTestMode.None)

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
          vertical: 8,
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
          top: 8,
          right: 16
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放/暂停按钮
      PLVMediaPlayerPlayButtonFeedPort()
        .id(this.ids.plv_media_player_play_button)
        .width(80)
        .height(80)
        .alignRules({
          center: toCenterOf(parent),
          middle: toMiddleOf(parent)
        })
        .offset({
          y: this.videoOffsetY
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放进度文本
      PLVMediaPlayerProgressTextView()
        .id(this.ids.plv_media_player_progress_text_view)
        .margin({
          left: 16,
          bottom: 16
        })
        .alignRules({
          left: toStartOf(parent),
          bottom: toBottomOf(parent)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 切换全屏按钮
      PLVMediaPlayerSwitchToFullScreenButtonFeedPort()
        .id(this.ids.plv_media_player_switch_full_screen_btn)
        .margin({
          top: 8
        })
        .offset({
          y: this.videoOffsetY
        })
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_feed_video_shadow),
          middle: toMiddleOf(parent)
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // 播放进度条
      PLVMediaPlayerProgressSliderFeedPort()
        .id(this.ids.plv_media_player_progress_slider)
        .width('100%')
        .height(14)
        .padding(usePadding({
          horizontal: 8
        }))
        .margin({
          bottom: 9
        })
        .alignRules({
          bottom: toTopOf(this.ids.plv_media_player_progress_text_view)
        })

      // 弱网提示
      PLVMediaPlayerNetworkPoorIndicateLayout()
        .id(this.ids.plv_media_player_network_poor_indicate_layout)
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_more_action_iv),
          right: toEndOf(parent)
        })
        .margin({
          right: 8
        })

      // 长按快进控制提示
      PLVMediaPlayerLongPressSpeedHintLayout()
        .id(this.ids.plv_media_player_long_press_speed_hint_layout)
        .alignRules({
          middle: toMiddleOf(parent),
          bottom: toBottomOf(parent)
        })
        .margin({
          bottom: 160
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
          bottom: 6
        })

      // 切换清晰度提示条
      PLVMediaPlayerSwitchBitRateHintLayout()
        .id(this.ids.plv_media_player_switch_bit_rate_hint_layout)
        .alignRules({
          top: toTopOf(parent),
          middle: toMiddleOf(parent)
        })
        .margin({
          top: 44
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
struct PLVMediaPlayerSingleVideoControllerLayoutPortPreview {
  @Provide dependScope: DependScope = createDependScope(commonItemModule)

  build() {
    PLVMediaPlayerFeedVideoControllerLayoutPort()
  }
}