import {
  DependScope,
  Disposable,
  isTextBlank,
  lateInit,
  MutableObserver,
  mutableStateOf,
  runCatching,
  watchStates
} from '@polyvharmony/media-player-sdk';
import { PLVMPDanmuViewModel } from '../../../modules/danmu/viewmodel/PLVMPDanmuViewModel';
import {
  defineIds,
  parent,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toStartOf,
  toTopOf,
  usePadding
} from '../../../utils/arkts-no-everything';
import { PLVMediaPlayerDanmuMode } from '@polyvharmony/media-player-sdk-addon-business';
import { PLVMPDanmuSize } from '../../../modules/danmu/viewmodel/viewstate/PLVMPDanmuStyleViewState';
import { PLVKeyboardManager } from '../../../utils/PLVKeyboardManager';
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel';
import {
  ON_BACK_PRESS_PRIORITY_TEXT_INPUT,
  PLVMPPageControlViewModel
} from '../../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel';

const DANMU_COLORS = [0xFFFFFFFF, 0xFFE15241, 0xFF9031AA, 0xFF4BA6EE, 0xFF67AD5B, 0xFFF8D86E]
const DANMU_MODES = [PLVMediaPlayerDanmuMode.ROLL_RIGHT_TO_LEFT, PLVMediaPlayerDanmuMode.FIX_TOP, PLVMediaPlayerDanmuMode.FIX_BOTTOM]
const DANMU_SIZE = [PLVMPDanmuSize.SMALL, PLVMPDanmuSize.MEDIUM, PLVMPDanmuSize.LARGE]

@Component
export struct PLVMediaPlayerDanmuInputLayout {
  @Consume dependScope: DependScope
  @Consume pageDependScope: DependScope
  private readonly mediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private readonly danmuViewModel = this.dependScope.get(PLVMPDanmuViewModel)
  private readonly pageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private readonly isFocusInput = mutableStateOf(false)
  @State private isVisible: boolean = false
  @State private isStyleSettingVisible: boolean = false
  @State private inputContent: string = ''
  @State private currentColor: number = DANMU_COLORS[0]
  @State private currentMode: PLVMediaPlayerDanmuMode = DANMU_MODES[0]
  @State private currentSize: PLVMPDanmuSize = DANMU_SIZE[0]
  @State private keyboardHeight: number = 0
  private pausePlayerOnShowDanmuInput: boolean = false
  private onBackPressDisposable: Disposable = lateInit()
  private readonly ids = defineIds(
    'plv_media_player_danmu_input_container',
    'plv_media_player_danmu_style_setting_iv',
    'plv_media_player_danmu_content_et',
    'plv_media_player_danmu_send_tv',
    'plv_media_player_danmu_style_layout',
    'plv_media_player_danmu_style_color_layout',
    'plv_media_player_danmu_style_color_tv',
    'plv_media_player_danmu_style_mode_layout',
    'plv_media_player_danmu_style_mode_tv',
    'plv_media_player_danmu_style_size_layout',
    'plv_media_player_danmu_style_size_tv',
    'plv_media_player_danmu_keyboard_inset_bottom'
  )
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.danmuViewModel.inputLayoutVisible.observe((isVisible) => {
      this.isVisible = isVisible
      if (this.isVisible) {
        setTimeout(() => {
          runCatching(() => {
            this.getUIContext().getFocusController().requestFocus(this.ids.plv_media_player_danmu_content_et)
          })
        }, 20)
      }
    }).pushTo(this.observers)
    this.danmuViewModel.inputLayoutVisible.observe((isVisible) => {
      if (isVisible) {
        const isPlaying = this.mediaViewModel.mediaPlayViewState.value?.isPlaying ?? false
        if (isPlaying) {
          this.mediaViewModel.pause()
          this.pausePlayerOnShowDanmuInput = true
        }
      } else {
        if (this.pausePlayerOnShowDanmuInput) {
          this.mediaViewModel.start()
        }
        this.pausePlayerOnShowDanmuInput = false
      }
    }).pushTo(this.observers)
    this.danmuViewModel.danmuStyle.observe((viewState) => {
      this.currentColor = viewState.color
      this.currentMode = viewState.mode
      this.currentSize = viewState.size
    }).pushTo(this.observers)
    watchStates(() => {
      this.keyboardHeight = PLVKeyboardManager.getInstance().keyboardHeight.value?.vp ?? 0
    }).pushTo(this.observers)
    this.onBackPressDisposable = this.pageControlViewModel.onBackPressHandler.register(ON_BACK_PRESS_PRIORITY_TEXT_INPUT, () => this.handleBackPress())
  }

  build() {
    RelativeContainer() {
      RelativeContainer() {
        Image($r('app.media.plv_media_player_danmu_style_setting_icon'))
          .id(this.ids.plv_media_player_danmu_style_setting_iv)
          .width(32)
          .height(32)
          .objectFit(ImageFit.Contain)
          .margin({
            left: 16
          })
          .alignRules({
            start: toStartOf(parent),
            center: toCenterOf(parent)
          })
          .onClick(() => {
            this.isStyleSettingVisible = !this.isStyleSettingVisible
            this.getUIContext().getFocusController().clearFocus()
          })

        TextInput({
          placeholder: $r('app.string.plv_media_player_danmu_content_hint'),
          text: this.inputContent
        })
          .id(this.ids.plv_media_player_danmu_content_et)
          .height(32)
          .margin(usePadding({
            horizontal: 16
          }))
          .backgroundColor('#FFFFFF')
          .borderRadius(6)
          .alignRules({
            start: toEndOf(this.ids.plv_media_player_danmu_style_setting_iv),
            end: toStartOf(this.ids.plv_media_player_danmu_send_tv),
            center: toCenterOf(parent)
          })
          .onAppear(() => {
            focusControl.requestFocus(this.ids.plv_media_player_danmu_content_et)
          })
          .onFocus(() => {
            this.isFocusInput.setValue(true)
            this.isStyleSettingVisible = false
          })
          .onBlur(() => {
            this.isFocusInput.setValue(false)
          })
          .onChange((content) => {
            this.inputContent = content
          })
          .onSubmit(() => {
            this.onSendDanmu()
          })

        Text($r('app.string.plv_media_player_danmu_send'))
          .id(this.ids.plv_media_player_danmu_send_tv)
          .height(32)
          .fontColor('#FFFFFF')
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .margin({
            right: 16
          })
          .alignRules({
            end: toEndOf(parent),
            center: toCenterOf(parent)
          })
          .onClick(() => {
            this.onSendDanmu()
          })
      }
      .id(this.ids.plv_media_player_danmu_input_container)
      .width('100%')
      .height(64)
      .padding(usePadding({
        vertical: 16
      }))
      .backgroundColor('#000000')
      .alignRules({
        bottom: toTopOf(this.ids.plv_media_player_danmu_style_layout)
      })
      .onClick(() => {
      })

      Column() {
        RelativeContainer() {
          Text($r('app.string.plv_media_player_danmu_color'))
            .id(this.ids.plv_media_player_danmu_style_color_tv)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .alignRules({
              top: toTopOf(parent),
              start: toStartOf(parent)
            })

          Row({ space: 16 }) {
            ForEach(
              DANMU_COLORS,
              (color: number) => {
                Stack() {
                  if (this.currentColor === color) {
                    Circle()
                      .width(20)
                      .height(20)
                      .fillOpacity(0)
                      .stroke(color)
                      .strokeWidth(2)
                  }
                  Circle()
                    .width(16)
                    .height(16)
                    .fill(color)
                }
                .width(20)
                .height(20)
                .onClick(() => {
                  this.danmuViewModel.setDanmuColor(color)
                })
              }
            )
          }
          .margin({
            left: 16
          })
          .alignRules({
            start: toEndOf(this.ids.plv_media_player_danmu_style_color_tv),
            center: toCenterOf(this.ids.plv_media_player_danmu_style_color_tv)
          })
        }
        .id(this.ids.plv_media_player_danmu_style_color_layout)
        .width('100%')
        .height(56)
        .padding(usePadding({
          horizontal: 32
        }))

        RelativeContainer() {
          Text($r('app.string.plv_media_player_danmu_mode'))
            .id(this.ids.plv_media_player_danmu_style_mode_tv)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .alignRules({
              top: toTopOf(parent),
              start: toStartOf(parent)
            })

          Row({ space: 16 }) {
            ForEach(
              DANMU_MODES,
              (mode: PLVMediaPlayerDanmuMode) => {
                Text(this.danmuModeTextMapping(mode))
                  .fontColor(this.currentMode.text == mode.text ? '#31adfe' : '#FFFFFF')
                  .fontSize(16)
                  .onClick(() => {
                    this.danmuViewModel.setDanmuMode(mode)
                  })
              }
            )
          }
          .margin({
            left: 16
          })
          .alignRules({
            start: toEndOf(this.ids.plv_media_player_danmu_style_mode_tv),
            center: toCenterOf(this.ids.plv_media_player_danmu_style_mode_tv)
          })
        }
        .id(this.ids.plv_media_player_danmu_style_mode_layout)
        .width('100%')
        .height(56)
        .padding(usePadding({
          horizontal: 32
        }))

        RelativeContainer() {
          Text($r('app.string.plv_media_player_danmu_size'))
            .id(this.ids.plv_media_player_danmu_style_size_tv)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .alignRules({
              top: toTopOf(parent),
              start: toStartOf(parent)
            })

          Row({ space: 16 }) {
            ForEach(
              DANMU_SIZE,
              (size: PLVMPDanmuSize) => {
                Text(size.value.toString())
                  .fontColor(this.currentSize.value == size.value ? '#31adfe' : '#FFFFFF')
                  .fontSize(16)
                  .onClick(() => {
                    this.danmuViewModel.setDanmuSize(size)
                  })
              }
            )
          }
          .margin({
            left: 16
          })
          .alignRules({
            start: toEndOf(this.ids.plv_media_player_danmu_style_size_tv),
            center: toCenterOf(this.ids.plv_media_player_danmu_style_size_tv)
          })
        }
        .id(this.ids.plv_media_player_danmu_style_size_layout)
        .width('100%')
        .height(56)
        .padding(usePadding({
          horizontal: 32
        }))
      }
      .id(this.ids.plv_media_player_danmu_style_layout)
      .width('100%')
      .visibility(this.isStyleSettingVisible ? Visibility.Visible : Visibility.None)
      .backgroundColor('#000000')
      .padding(usePadding({
        vertical: 16
      }))
      .alignRules({
        bottom: toTopOf(this.ids.plv_media_player_danmu_keyboard_inset_bottom)
      })
      .onClick(() => {
      })

      Column()
        .id(this.ids.plv_media_player_danmu_keyboard_inset_bottom)
        .height(this.keyboardHeight)
        .alignRules({
          bottom: toBottomOf(parent)
        })
    }
    .width('100%')
    .height('100%')
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.handleBackPress()
    })
  }

  private async onSendDanmu() {
    const content = this.inputContent
    if (isTextBlank(content)) {
      return
    }
    const result = await runCatching(this.danmuViewModel.sendDanmu(content))
    if (result.success) {
      this.inputContent = ''
      this.isStyleSettingVisible = false
      this.getUIContext().getFocusController().clearFocus()
      this.danmuViewModel.setInputLayoutVisible(false)
    }
  }

  private handleBackPress(): boolean {
    if (this.isStyleSettingVisible) {
      this.isStyleSettingVisible = false
      return true
    }
    if (this.isFocusInput.value ?? false) {
      this.getUIContext().getFocusController().clearFocus()
      return true
    }
    if (this.isVisible) {
      this.danmuViewModel.setInputLayoutVisible(false)
      return true
    }
    return false
  }

  private danmuModeTextMapping(mode: PLVMediaPlayerDanmuMode): ResourceStr {
    switch (mode) {
      case PLVMediaPlayerDanmuMode.ROLL_RIGHT_TO_LEFT:
        return $r('app.string.plv_media_player_danmu_mode_roll')
      case PLVMediaPlayerDanmuMode.FIX_TOP:
        return $r('app.string.plv_media_player_danmu_mode_top')
      case PLVMediaPlayerDanmuMode.FIX_BOTTOM:
        return $r('app.string.plv_media_player_danmu_mode_bottom')
    }
    return $r('app.string.plv_media_player_danmu_mode')
  }

  aboutToDisappear(): void {
    this.onBackPressDisposable.dispose()
    MutableObserver.disposeAll(this.observers)
  }
}