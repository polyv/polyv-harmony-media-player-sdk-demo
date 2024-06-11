import {MutableState} from '@polyvharmony/media-player-sdk';
import {PLVMPProgressImageRepo} from "../model/PLVMPProgressImageRepo";
import {DecodeProgressImageUseCase} from './usecase/DecodeProgressImageUseCase';
import image from '@ohos.multimedia.image';

export class PLVMPProgressImageViewModel {

  private readonly repo: PLVMPProgressImageRepo
  private readonly decodeProgressImageUseCase: DecodeProgressImageUseCase

  readonly progressImage: MutableState<image.PixelMap | null> = new MutableState(null)

  private lastUpdateProgressIndex: number = -1
  private isUpdatingProgressImage: boolean = false

  constructor(
    repo: PLVMPProgressImageRepo,
    decodeProgressImageUseCase: DecodeProgressImageUseCase
  ) {
    this.repo = repo
    this.decodeProgressImageUseCase = decodeProgressImageUseCase
  }

  async updateProgressImage(positionMs: number): Promise<void> {
    const mediaInfo = this.repo.mediaMediator.mediaInfo?.apply(null)
    if (mediaInfo === undefined || mediaInfo.progressPreviewImageInterval <= 0) {
      this.progressImage.value = null
      return
    }
    const index = Math.floor(positionMs / 1000 / mediaInfo.progressPreviewImageInterval)
    if (index === this.lastUpdateProgressIndex || this.isUpdatingProgressImage) {
      return
    }
    this.lastUpdateProgressIndex = index
    this.isUpdatingProgressImage = true

    try {
      const sourceImage = await this.repo.getProgressImage()
      if (sourceImage === null) {
        this.progressImage.value = null
        return
      }
      this.progressImage.value = await this.decodeProgressImageUseCase.decode(sourceImage, index)
    } catch (e) {
      this.progressImage.value = null
    } finally {
      this.isUpdatingProgressImage = false
    }
  }

}