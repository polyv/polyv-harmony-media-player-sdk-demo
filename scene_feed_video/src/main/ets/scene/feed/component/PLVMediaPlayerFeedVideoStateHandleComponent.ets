import {
  DependScope,
  MutableObserver,
  PLVMediaPlayerOptionEnum,
  PLVMediaPlayerState
} from '@polyvharmony/media-player-sdk'
import {
  PLVMPMediaControllerViewModel,
  PLVMPMediaViewModel,
  PLVMPPageControlViewModel
} from 'media-player-common'

@Component
export struct PLVMediaPlayerFeedVideoStateHandleComponent {
  mediaResourceIndex?: number
  @Consume dependScope: DependScope
  @Consume pageDependScope: DependScope
  private viewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel);
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel);
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private startOnPlayerPreparedObserver: MutableObserver | null = null
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.pageControlViewModel.currentItemIndex.observe((index: number) => {
      const currentItemVisible = this.mediaResourceIndex === index
      if (currentItemVisible) {
        this.viewModel.setPlayerOption([PLVMediaPlayerOptionEnum.START_ON_PREPARED.value("1")])
        this.startPlayer()
      } else {
        this.viewModel.setPlayerOption([PLVMediaPlayerOptionEnum.START_ON_PREPARED.value("0")])
        this.pausePlayer()
      }
    }).pushTo(this.observers)
  }

  build() {
  }

  private startPlayer() {
    this.viewModel.start()
    this.startOnPlayerPreparedObserver = this.viewModel.playerState.observe((playerState) => {
      if (playerState === PLVMediaPlayerState.STATE_PREPARED) {
        this.viewModel.start()
        this.startOnPlayerPreparedObserver?.dispose()
      }
    })
  }

  private pausePlayer() {
    this.startOnPlayerPreparedObserver?.dispose()
    this.viewModel.pause()
  }

  aboutToDisappear(): void {
    this.startOnPlayerPreparedObserver?.dispose()
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}