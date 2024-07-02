import { DependScope } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaControllerViewModel, PLVMPMediaViewModel } from 'media-player-common'

@Component
export struct PLVMediaPlayerGestureHandleLayoutFeedPort {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 1 })
          .onAction(() => {
            this.onSingleClick()
          }),
        LongPressGesture()
          .onAction((event: GestureEvent) => {
            this.controllerViewModel.handleLongPressSpeeding('start')
          })
          .onActionEnd((event: GestureEvent) => {
            this.controllerViewModel.handleLongPressSpeeding('end')
          })
          .onActionCancel(() => {
            this.controllerViewModel.handleLongPressSpeeding('end')
          }),
      )
    )
  }

  private onSingleClick() {
    if (this.mediaViewModel.mediaPlayViewState.value?.isPlaying) {
      this.mediaViewModel.pause()
    } else {
      this.mediaViewModel.start()
    }
  }
}
