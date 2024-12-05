import { DependScope, lateInit, logger, MutableObserver, runCatching } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isLandscape } from '../../utils/PLVDisplayUtils'
import { image } from '@kit.ImageKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import fs from '@ohos.file.fs'
import { promptAction } from '@kit.ArkUI'
import { any, usePadding } from '../../utils/arkts-no-everything'

const TAG = "PLVMediaPlayerScreenshotImageView"

@Component
export struct PLVMediaPlayerScreenshotImageView {
  @Consume dependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = viewState.controllerVisible
        && !viewState.isMediaStopOverlayVisible()
        && !viewState.controllerLocking
        && !(viewState.isFloatActionLayoutVisible() && isLandscape())
    }).pushTo(this.observers)
  }

  build() {
    Image($r('app.media.plv_media_player_screenshot_icon'))
      .width(40)
      .height(40)
      .padding(8)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .onClick(async () => {
        const result = await runCatching(this.screenshot())
        if (!result.success) {
          logger.error(TAG, `screenshot failed: ${any(result).error}`)
        }
        if (!result.success || !result.data) {
          promptAction.showToast({ message: $r('app.string.plv_media_player_ui_component_screenshot_save_failed') })
          return
        }
        const pixelMap = result.data
        this.showSaveImageDialog(pixelMap)
      })
  }

  private async screenshot(): Promise<PixelMap | null> {
    return await this.viewModel.onScreenshot?.() ?? null
  }

  private showSaveImageDialog(pixelMap: PixelMap) {
    const controller = new CustomDialogController({
      builder: SaveImageDialog({ pixelMap: pixelMap })
    })
    controller.open()
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}

@CustomDialog
struct SaveImageDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: SaveImageDialog()
  })
  pixelMap: PixelMap = lateInit()

  build() {
    Column() {

      Text($r('app.string.plv_media_player_ui_component_screenshot_save_to_local'))
        .fontSize(16)

      Image(this.pixelMap)
        .width(160)
        .height(160)
        .margin(usePadding({
          vertical: 8
        }))
        .objectFit(ImageFit.Contain)

      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,
        text: SaveDescription.SAVE_IMAGE
      })
        .onClick(async () => {
          const result = await runCatching(this.saveImage())
          if (result.success) {
            promptAction.showToast({ message: $r('app.string.plv_media_player_ui_component_screenshot_save_success') })
          } else {
            logger.error(TAG, `screenshot failed: ${any(result).error}`)
            promptAction.showToast({ message: $r('app.string.plv_media_player_ui_component_screenshot_save_failed') })
          }
        })
    }
    .padding(usePadding({
      vertical: 12
    }))
  }

  private async saveImage() {
    const photoAccess = photoAccessHelper.getPhotoAccessHelper(getContext(this))
    const uri = await photoAccess.createAsset(photoAccessHelper.PhotoType.IMAGE, "png")
    const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    const packer = image.createImagePacker()
    await packer.packToFile(this.pixelMap, file.fd, {
      format: "image/png",
      quality: 100
    })
    await packer.release()
    await fs.close(file)
  }
}