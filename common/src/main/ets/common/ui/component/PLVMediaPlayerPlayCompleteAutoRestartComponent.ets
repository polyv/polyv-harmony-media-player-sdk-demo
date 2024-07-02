import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'

@Component
export struct PLVMediaPlayerPlayCompleteAutoRestartComponent {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.onCompleteEvent.observe((event) => [
      this.mediaViewModel.restart()
    ]).pushTo(this.observers)
  }

  build() {

  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}