import { PLVMediaCastDevice, PLVMediaCastManager } from '@polyvharmony/media-cast'
import {
  DependScope,
  lateInit,
  MutableObserver,
  runCatching,
  seconds,
  watchStates
} from '@polyvharmony/media-player-sdk'
import { PLVMPCastViewModel } from '../../../../modules/cast/viewmodel/PLVMPCastViewModel'
import {
  defineIds,
  parent,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf
} from '../../../../utils/arkts-no-everything'
import { PLVOrientationManager } from '../../../../utils/PLVOrientationManager'

@CustomDialog
export struct PLVMediaPlayerCastDeviceSelectLayout {
  controller: CustomDialogController = lateInit()
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isPortrait: boolean = true
  @State private devices: PLVMediaCastDevice[] = []
  @State private currentCastDevice: PLVMediaCastDevice | undefined = undefined
  @State private isScanningDevice: boolean = false
  private readonly ids = defineIds(
    'plv_media_player_cast_search_device_title',
    'plv_media_player_cast_search_device_result_title',
    'plv_media_player_cast_search_iv',
    'plv_media_player_cast_search_divider'
  )
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(() => {
      this.isPortrait = PLVOrientationManager.getInstance().isPortrait.value ?? true
    }).pushTo(this.observers)
    watchStates(() => {
      this.devices = PLVMediaCastManager.getInstance().listenerRegistry.devices.value ?? []
    }).pushTo(this.observers)
    watchStates(() => {
      this.currentCastDevice = this.castViewModel.currentCastDevice.value
    }).pushTo(this.observers)

    this.runScanDevice()
  }

  build() {
    RelativeContainer() {
      Text($r('app.string.plv_media_player_cast_search_device_title'))
        .id(this.ids.plv_media_player_cast_search_device_title)
        .fontColor('#333333')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          middle: toMiddleOf(parent),
          top: toTopOf(parent)
        })
        .margin({
          top: 20
        })

      Text($r('app.string.plv_media_player_cast_search_device_result_title'))
        .id(this.ids.plv_media_player_cast_search_device_result_title)
        .fontColor('#333333')
        .fontSize(14)
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_cast_search_device_title),
          left: toStartOf(parent)
        })
        .margin({
          left: 15,
          top: 30
        })

      Image(this.isScanningDevice ? $r('app.media.plv_media_player_cast_searching') : $r('app.media.plv_media_player_cast_refresh'))
        .id(this.ids.plv_media_player_cast_search_iv)
        .width(35)
        .height(35)
        .padding(5)
        .alignRules({
          center: toCenterOf(this.ids.plv_media_player_cast_search_device_result_title),
          right: toEndOf(parent)
        })
        .margin({
          right: 15
        })
        .onClick(() => {
          this.runScanDevice()
        })

      Divider()
        .id(this.ids.plv_media_player_cast_search_divider)
        .vertical(false)
        .width('100%')
        .height(1)
        .color('#E5E5E5')
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_cast_search_device_result_title)
        })
        .margin({
          top: 10
        })

      Image($r('app.media.plv_media_player_cast_search_bg_icon'))
        .width(125)
        .alignRules({
          left: toStartOf(parent),
          bottom: toBottomOf(parent)
        })

      if (!this.isScanningDevice && this.devices.length == 0) {
        Column() {
          Image($r('app.media.plv_media_player_cast_no_device'))
            .width(250)

          Text($r('app.string.plv_media_player_cast_search_device_result_not_found'))
            .fontColor('#333333')
            .fontSize(16)
            .margin({
              top: 20
            })

          Text($r('app.string.plv_media_player_cast_search_device_retry'))
            .width(160)
            .height(40)
            .textAlign(TextAlign.Center)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .backgroundColor('#56ACE9')
            .borderRadius(20)
            .margin({
              top: 12
            })
            .onClick(() => {
              this.runScanDevice()
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_cast_search_divider)
        })
        .margin({
          top: this.isPortrait ? 90 : 10
        })
      } else {
        Stack() {
          Scroll() {
            Column() {
              ForEach(
                this.devices,
                (device: PLVMediaCastDevice) => {
                  Row() {
                    Image(this.isSameDevice(this.currentCastDevice, device) ? $r('app.media.plv_media_player_cast_device_white') : $r('app.media.plv_media_player_cast_device_black'))
                      .width(15)
                      .height(15)
                      .objectFit(ImageFit.Contain)
                      .margin({
                        left: 15
                      })

                    Text(device.friendlyName)
                      .fontColor(this.isSameDevice(this.currentCastDevice, device) ? '#FFFFFF' : '#000000')
                      .fontSize(16)
                      .layoutWeight(1)
                      .padding({
                        left: 15,
                        right: 15,
                        top: 12,
                        bottom: 12
                      })

                    if (this.isSameDevice(this.currentCastDevice, device)) {
                      Image($r('app.media.plv_media_player_cast_device_selected_icon'))
                        .width(15)
                        .height(15)
                        .objectFit(ImageFit.Contain)
                        .margin({
                          right: 20
                        })
                    }
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  .linearGradient(
                    this.isSameDevice(this.currentCastDevice, device) ?
                      {
                        angle: 90,
                        colors: [
                          ['#56ACE9', 0],
                          ['#8FD6F6', 1]
                        ]
                      }
                      : undefined
                  )
                  .borderRadius(4)
                  .margin({
                    left: 15,
                    right: 15,
                    top: 5
                  })
                  .onClick(() => {
                    if (!this.isSameDevice(this.currentCastDevice, device)) {
                      this.controller.close()
                      this.castViewModel.startCast(device)
                    }
                  })
                },
                (device: PLVMediaCastDevice) => device.location
              )
            }
          }
        }
        .width('100%')
        .alignContent(Alignment.Top)
        .margin({
          top: 10
        })
        .padding({
          left: 15,
          right: 15
        })
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_cast_search_divider),
          bottom: toBottomOf(parent)
        })
      }
    }
    .width(this.isPortrait ? '100%' : 375)
    .height(this.isPortrait ? '65%' : '100%')
    .borderRadius({
      topLeft: 16,
      topRight: this.isPortrait ? 16 : 0,
      bottomLeft: this.isPortrait ? 0 : 16
    })
    .backgroundColor('#FFFFFF')
  }

  private async runScanDevice() {
    if (this.isScanningDevice) {
      return
    }
    this.isScanningDevice = true
    await runCatching(PLVMediaCastManager.getInstance().scanDevices(seconds(5)))
    this.isScanningDevice = false
  }

  private isSameDevice(device1: PLVMediaCastDevice | null | undefined, device2: PLVMediaCastDevice | null | undefined): boolean {
    return device1?.location === device2?.location
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}