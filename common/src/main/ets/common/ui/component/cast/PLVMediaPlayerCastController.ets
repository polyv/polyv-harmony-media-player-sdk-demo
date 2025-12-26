import { PLVMediaCastDevice } from '@polyvharmony/media-cast';
import {
  deepEquals,
  DependScope,
  lateInit,
  MutableObserver,
  PLVMediaBitRate,
  watchStates
} from '@polyvharmony/media-player-sdk';
import { PLVMPCastViewModel } from '../../../modules/cast/viewmodel/PLVMPCastViewModel';
import {
  defineIds,
  parent,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf,
  usePadding
} from '../../../utils/arkts-no-everything';
import { PLVOrientationManager } from '../../../utils/PLVOrientationManager';
import { PLVMediaPlayerCastBackImageView } from './widget/PLVMediaPlayerCastBackImageView';
import { PLVMediaPlayerCastDeviceSelectLayout } from './widget/PLVMediaPlayerCastDeviceSelectLayout';
import { PLVMediaPlayerCastPlayPauseButton } from './widget/PLVMediaPlayerCastPlayPauseButton';
import { PLVMediaPlayerCastProgressLayout } from './widget/PLVMediaPlayerCastProgressLayout';
import { PLVMediaPlayerCastStopButton } from './widget/PLVMediaPlayerCastStopButton';
import { PLVMediaPlayerCastToggleOrientationButton } from './widget/PLVMediaPlayerCastToggleOrientationButton';

@Component
export struct PLVMediaPlayerCastController {
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private currentCastDevice: PLVMediaCastDevice | undefined = undefined
  @State private supportBitRates: PLVMediaBitRate[] = []
  @State private currentBitRate: PLVMediaBitRate | undefined = undefined
  private readonly deviceSelectDialog = new CustomDialogController({
    builder: PLVMediaPlayerCastDeviceSelectLayout(),
    alignment: DialogAlignment.BottomEnd,
    customStyle: true
  })
  private readonly switchBitrateDialog = new CustomDialogController({
    builder: PLVLWCastBitRateSelectDialog(),
    alignment: DialogAlignment.BottomEnd,
    customStyle: true
  })
  private readonly ids = defineIds(
    'plv_media_player_cast_play_pause_button',
    'plv_media_player_cast_progress_layout',
    'plv_media_player_cast_toggle_orientation_button',
  )
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(() => {
      this.currentCastDevice = this.castViewModel.currentCastDevice.value
    }).pushTo(this.observers)
    watchStates(() => {
      this.supportBitRates = this.castViewModel.castSupportBitRates.value ?? []
      this.currentBitRate = this.castViewModel.castBitRate.value
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      PLVMediaPlayerCastBackImageView()
        .width(36)
        .height(36)
        .padding(6)
        .alignRules({
          top: toTopOf(parent),
          left: toStartOf(parent)
        })
        .margin({
          top: 8,
          left: 8
        })

      PLVMediaPlayerCastPlayPauseButton()
        .id(this.ids.plv_media_player_cast_play_pause_button)
        .width(36)
        .height(36)
        .padding(6)
        .alignRules({
          left: toStartOf(parent),
          bottom: toBottomOf(parent)
        })
        .margin({
          left: 8,
          bottom: 8
        })

      PLVMediaPlayerCastProgressLayout()
        .id(this.ids.plv_media_player_cast_progress_layout)
        .alignRules({
          left: toEndOf(this.ids.plv_media_player_cast_play_pause_button),
          right: toStartOf(this.ids.plv_media_player_cast_toggle_orientation_button),
          center: toCenterOf(this.ids.plv_media_player_cast_play_pause_button)
        })
        .margin(usePadding({
          horizontal: 8
        }))

      PLVMediaPlayerCastToggleOrientationButton()
        .id(this.ids.plv_media_player_cast_toggle_orientation_button)
        .width(36)
        .height(36)
        .alignRules({
          right: toEndOf(parent),
          bottom: toBottomOf(parent)
        })
        .margin({
          right: 8,
          bottom: 8
        })

      PLVMediaPlayerCastStopButton()
        .width(36)
        .height(36)
        .alignRules({
          right: toEndOf(parent),
          top: toTopOf(parent)
        })
        .margin({
          right: 8,
          top: 8
        })

      Column() {
        Stack() {
          Image($r('app.media.plv_media_player_cast_status_bg'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)

          Column() {
            Text(this.currentCastDevice?.friendlyName)
              .fontColor('#FFFFFF')
              .fontSize(16)

            Text($r('app.string.plv_media_player_cast_connect_device_switch'))
              .fontColor('#CCCCCC')
              .fontSize(12)
              .padding(5)
              .onClick(() => {
                this.deviceSelectDialog.open()
              })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(195)
        .height(56)

        if (this.supportBitRates.length > 1 && this.currentBitRate) {
          Text(this.currentBitRate.name)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .padding({
              left: 20,
              right: 20,
              top: 5,
              bottom: 5
            })
            .borderRadius(15)
            .borderColor('#FFFFFF')
            .borderWidth(1)
            .margin({
              top: 20
            })
            .onClick(() => {
              this.switchBitrateDialog.open()
            })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .alignRules({
        center: toCenterOf(parent),
        middle: toMiddleOf(parent)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .onClick(() => {
    })
  }
}

@CustomDialog
struct PLVLWCastBitRateSelectDialog {
  controller: CustomDialogController = lateInit()
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isPortrait: boolean = true
  @State private supportBitRates: PLVMediaBitRate[] = []
  @State private currentBitRate: PLVMediaBitRate | undefined = undefined
  private readonly ids = defineIds(
    'plvlw_more_bit_rate_title'
  )
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(() => {
      this.isPortrait = PLVOrientationManager.getInstance().isPortrait.value ?? true
    }).pushTo(this.observers)
    watchStates(() => {
      this.supportBitRates = this.castViewModel.castSupportBitRates.value ?? []
      this.currentBitRate = this.castViewModel.castBitRate.value
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Text($r('app.string.plv_media_player_bitrate_definition'))
        .id(this.ids.plvlw_more_bit_rate_title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#CC000000')
        .alignRules({
          middle: toMiddleOf(parent),
          top: toTopOf(parent)
        })
        .margin({
          top: 15
        })

      List({
        space: 8
      }) {
        ForEach(
          this.supportBitRates,
          (bitRate: PLVMediaBitRate) => {
            ListItem() {
              Text(bitRate.name)
                .width('100%')
                .height(56)
                .textAlign(TextAlign.Center)
                .fontSize(14)
                .fontColor(deepEquals(bitRate, this.currentBitRate) ? '#3F76FC' : '#CC000000')
                .border({
                  radius: 8,
                  color: deepEquals(bitRate, this.currentBitRate) ? '#3F76FC' : '#FFFFFF',
                  width: 1
                })
                .backgroundColor(deepEquals(bitRate, this.currentBitRate) ? '#1A3F76FC' : '#FFFFFF')
            }
            .onClick(() => {
              if (!deepEquals(bitRate, this.currentBitRate)) {
                this.castViewModel.switchBitRate(bitRate)
                this.controller.close()
              }
            })
          },
          (bitRate: PLVMediaBitRate) => bitRate.index.toString()
        )
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
      .alignRules({
        top: toBottomOf(this.ids.plvlw_more_bit_rate_title),
        bottom: toBottomOf(parent)
      })
      .margin({
        top: 27,
        bottom: 46
      })
    }
    .width(this.isPortrait ? '100%' : 375)
    .height(this.isPortrait ? 294 : '100%')
    .backgroundColor('#F7F8FA')
    .borderRadius({
      topLeft: 16,
      topRight: this.isPortrait ? 16 : 0,
      bottomLeft: this.isPortrait ? 0 : 16
    })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
  }
}