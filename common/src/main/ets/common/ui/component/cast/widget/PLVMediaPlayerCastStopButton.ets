import { DependScope } from '@polyvharmony/media-player-sdk'
import { PLVMPCastViewModel } from '../../../../modules/cast/viewmodel/PLVMPCastViewModel'

@Component
export struct PLVMediaPlayerCastStopButton {
  @Consume dependScope: DependScope
  private readonly castViewModel = this.dependScope.get(PLVMPCastViewModel)

  build() {
    Image($r('app.media.plv_media_player_cast_stop_icon'))
      .padding(8)
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        this.castViewModel.stopCast()
      })
  }
}