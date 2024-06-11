import {LifecycleAwareDependComponent, MutableState} from '@polyvharmony/media-player-sdk'
import {PLVMPMediaRepo} from "../../model/PLVMPMediaRepo";

export class UpdateBufferingSpeedUseCase implements LifecycleAwareDependComponent {

  private readonly repo: PLVMPMediaRepo
  readonly bufferingSpeed: MutableState<number> = new MutableState<number>()

  private trafficSpeedIntervalId: number | null = null
  private lastTrafficCount: number = 0
  private lastTrafficTimestamp: number = 0

  constructor(
    repo: PLVMPMediaRepo
  ) {
    this.repo = repo

    this.observePlayerTrafficSpeed()
  }

  private observePlayerTrafficSpeed() {
    this.trafficSpeedIntervalId = setInterval(() => {
      if (this.lastTrafficTimestamp === 0) {
        this.lastTrafficCount = this.repo.player.getTrafficStatisticByteCount()
        this.lastTrafficTimestamp = Date.now()
        return
      }
      const newTrafficCount = this.repo.player.getTrafficStatisticByteCount()
      const newTrafficTimestamp = Date.now()
      const diffCount = newTrafficCount - this.lastTrafficCount
      const duration = newTrafficTimestamp - this.lastTrafficTimestamp
      const speed = diffCount / duration * 1000
      this.lastTrafficCount = newTrafficCount
      this.lastTrafficTimestamp = newTrafficTimestamp

      this.bufferingSpeed.value = speed
    }, 500)
  }

  onDestroy() {
    if (this.trafficSpeedIntervalId !== null) {
      clearInterval(this.trafficSpeedIntervalId)
    }
  }

}