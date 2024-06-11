import {PLVMPProgressImageLocalDataSource} from "./datasource/PLVMPProgressImageLocalDataSource";
import {PLVMPProgressImageNetworkDataSource} from "./datasource/PLVMPProgressImageNetworkDataSource";
import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";
import {PLVMPProgressImageData} from "./vo/PLVMPProgressImageData";

export class PLVMPProgressImageRepo {

  private readonly localDataSource: PLVMPProgressImageLocalDataSource
  private readonly networkDataSource: PLVMPProgressImageNetworkDataSource
  readonly mediaMediator: PLVMPMediaMediator

  constructor(
    localDataSource: PLVMPProgressImageLocalDataSource,
    networkDataSource: PLVMPProgressImageNetworkDataSource,
    mediaMediator: PLVMPMediaMediator
  ) {
    this.localDataSource = localDataSource
    this.networkDataSource = networkDataSource
    this.mediaMediator = mediaMediator
  }

  async getProgressImage(): Promise<PLVMPProgressImageData | null> {
    const mediaInfo = this.mediaMediator.mediaInfo?.apply(null)
    if (mediaInfo === undefined || mediaInfo.progressPreviewImage === null) {
      return null
    }
    let data = this.localDataSource.getProgressImage(mediaInfo.progressPreviewImage)
    if (data !== null) {
      return data
    }
    data = await this.networkDataSource.getProgressImage(mediaInfo.progressPreviewImage)
    this.localDataSource.cacheProgressImage(data)
    return data
  }

}