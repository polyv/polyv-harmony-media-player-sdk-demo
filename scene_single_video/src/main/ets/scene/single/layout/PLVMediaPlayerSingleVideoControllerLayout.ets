import { MutableObserver } from '@polyvharmony/media-player-sdk'
import { isPortrait, PLVOrientationManager } from 'media-player-common'
import { PLVMediaPlayerSingleVideoControllerLayoutLand } from './PLVMediaPlayerSingleVideoControllerLayoutLand'
import { PLVMediaPlayerSingleVideoControllerLayoutPort } from './PLVMediaPlayerSingleVideoControllerLayoutPort'

@Component
export struct PLVMediaPlayerSingleVideoControllerLayout {
  @State isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait: boolean) => {
      this.isPortrait = isPortrait
    }).pushTo(this.observers)
  }

  build() {
    if (this.isPortrait) {
      PLVMediaPlayerSingleVideoControllerLayoutPort()
    } else {
      PLVMediaPlayerSingleVideoControllerLayoutLand()
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}