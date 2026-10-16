import { MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  isPortrait,
  PLVMediaPlayerBitRateSelectLayoutLand,
  PLVMediaPlayerKnowledgeLayout,
  PLVMediaPlayerMoreLayoutLand,
  PLVMediaPlayerMoreLayoutPort,
  PLVMediaPlayerMoreSubtitleSettingLayoutLand,
  PLVMediaPlayerMoreSubtitleSettingLayoutPort,
  PLVMediaPlayerRouteSelectLayout,
  PLVMediaPlayerSpeedSelectLayoutLand,
  PLVOrientationManager
} from 'media-player-common'

@Component
export struct PLVMediaPlayerFeedVideoFloatActionLayout {
  @State isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait: boolean) => {
      this.isPortrait = isPortrait
    }).pushTo(this.observers)
  }

  build() {
    if (this.isPortrait) {
      PLVMediaPlayerRouteSelectLayout()
      PLVMediaPlayerMoreLayoutPort()
      PLVMediaPlayerMoreSubtitleSettingLayoutPort()
    } else {
      PLVMediaPlayerRouteSelectLayout()
      PLVMediaPlayerMoreLayoutLand()
      PLVMediaPlayerBitRateSelectLayoutLand()
      PLVMediaPlayerSpeedSelectLayoutLand()
      PLVMediaPlayerMoreSubtitleSettingLayoutLand()
      PLVMediaPlayerKnowledgeLayout()
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
