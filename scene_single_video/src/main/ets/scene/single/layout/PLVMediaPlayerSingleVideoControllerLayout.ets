import { DependScope, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk'
import { isPortrait, PLVMediaPlayerCastController, PLVOrientationManager } from 'media-player-common'
import { PLVMPCastViewModel } from 'media-player-common/src/main/ets/common/modules/cast/viewmodel/PLVMPCastViewModel'
import { PLVMediaPlayerSingleVideoControllerLayoutLand } from './PLVMediaPlayerSingleVideoControllerLayoutLand'
import { PLVMediaPlayerSingleVideoControllerLayoutPort } from './PLVMediaPlayerSingleVideoControllerLayoutPort'

@Component
export struct PLVMediaPlayerSingleVideoControllerLayout {
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)
  @State private isCasting: boolean = false
  @State private isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait: boolean) => {
      this.isPortrait = isPortrait
    }).pushTo(this.observers)
    watchStates(() => {
      this.isCasting = this.castViewModel.isCasting.value ?? false
    }).pushTo(this.observers)
  }

  build() {
    if (this.isCasting) {
      PLVMediaPlayerCastController()
    } else if (this.isPortrait) {
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