import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit';

export async function readFileAsPixelMap(url: string): Promise<PixelMap | null> {
  try {
    if (!await fs.access(url)) {
      return null
    }
    const file = await fs.open(url, fs.OpenMode.READ_ONLY)
    const size = (await fs.stat(file.fd)).size
    const buffer = new ArrayBuffer(size)
    await fs.read(file.fd, buffer)
    const imageSource = image.createImageSource(buffer)
    return await imageSource.createPixelMap({
      desiredPixelFormat: image.PixelMapFormat.RGB_565
    })
  } catch (e) {
    return null
  }
}