import { DependScope } from '@polyvharmony/media-player-sdk'
import { PLVMPPageControlViewModel } from '../../../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel'
import { isPortrait } from '../../../../utils/PLVDisplayUtils'
import { PLVOrientationManager } from '../../../../utils/PLVOrientationManager'

@Component
export struct PLVMediaPlayerCastBackImageView {
  @Consume pageDependScope: DependScope
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)

  build() {
    Image($r('app.media.plv_media_player_back_icon'))
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        if (isPortrait()) {
          const navPathStack: NavPathStack | undefined = this.pageControlViewModel.navPathStack
          navPathStack?.pop()
        } else {
          PLVOrientationManager.getInstance().requestOrientation('port');
        }
      })
  }
}