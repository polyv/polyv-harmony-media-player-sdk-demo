import { MutableObserver } from '@polyvharmony/media-player-sdk'
import { isPortrait, PLVOrientationManager } from 'media-player-common'
import { PLVMediaPlayerFeedVideoControllerLayoutLand } from './PLVMediaPlayerFeedVideoControllerLayoutLand'
import { PLVMediaPlayerFeedVideoControllerLayoutPort } from './PLVMediaPlayerFeedVideoControllerLayoutPort'

@Component
export struct PLVMediaPlayerFeedVideoControllerLayout {
  @State isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait: boolean) => {
      this.isPortrait = isPortrait
    }).pushTo(this.observers)
  }

  build() {
    if (this.isPortrait) {
      PLVMediaPlayerFeedVideoControllerLayoutPort()
    } else {
      PLVMediaPlayerFeedVideoControllerLayoutLand()
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}