import {LifecycleAwareDependComponent} from "@polyvharmony/media-player-sdk";
import {PLVMPProgressImageData} from "../vo/PLVMPProgressImageData";

export class PLVMPProgressImageLocalDataSource implements LifecycleAwareDependComponent {

  private cachedProgressImageData: PLVMPProgressImageData | null = null

  getProgressImage(url: string): PLVMPProgressImageData | null {
    if (this.cachedProgressImageData === null) {
      return null
    }
    if (this.cachedProgressImageData.url !== url) {
      this.cachedProgressImageData = null
      return null
    }
    return this.cachedProgressImageData
  }

  cacheProgressImage(data: PLVMPProgressImageData | null) {
    this.cachedProgressImageData = data
  }

  onDestroy() {
    this.cachedProgressImageData = null
  }

}