import {PLVMPProgressImageData} from "../../model/vo/PLVMPProgressImageData";
import image from '@ohos.multimedia.image';

const PREVIEW_IMAGES_EACH_ROW = 50;
const PREVIEW_IMAGES_WIDTH = 160;
const PREVIEW_IMAGES_HEIGHT = 90;

export class DecodeProgressImageUseCase {

  async decode(data: PLVMPProgressImageData, index: number): Promise<image.PixelMap | null> {
    const imageSource = image.createImageSource(data.buffer)
    if (imageSource === null || imageSource === undefined) {
      return null
    }
    return imageSource.createPixelMap({
      desiredRegion: this.getRegion(index),
      desiredPixelFormat: image.PixelMapFormat.RGB_565
    })
  }

  private getRegion(index: number): image.Region {
    const column = index % PREVIEW_IMAGES_EACH_ROW
    const row = Math.floor(index / PREVIEW_IMAGES_EACH_ROW)
    return {
      x: column * PREVIEW_IMAGES_WIDTH,
      y: row * PREVIEW_IMAGES_HEIGHT,
      size: {
        width: PREVIEW_IMAGES_WIDTH,
        height: PREVIEW_IMAGES_HEIGHT
      }
    }
  }

}