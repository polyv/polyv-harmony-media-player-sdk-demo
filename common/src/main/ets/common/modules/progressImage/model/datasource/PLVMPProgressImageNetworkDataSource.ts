import {PLVMPProgressImageData} from "../vo/PLVMPProgressImageData";
import {safe} from '@polyvharmony/media-player-sdk';
import http from '@ohos.net.http';

export class PLVMPProgressImageNetworkDataSource {

  async getProgressImage(url: string): Promise<PLVMPProgressImageData | null> {
    const networkResult = await safe(this.getHttpProgressImage(url))
    if (!networkResult.success || networkResult.data === null) {
      return null
    }

    return new PLVMPProgressImageData(url, networkResult.data)
  }

  private async getHttpProgressImage(url: string): Promise<ArrayBuffer | null> {
    const response = await http.createHttp().request(url)
    if (response.responseCode !== http.ResponseCode.OK) {
      return null
    }
    return response.result as ArrayBuffer
  }

}