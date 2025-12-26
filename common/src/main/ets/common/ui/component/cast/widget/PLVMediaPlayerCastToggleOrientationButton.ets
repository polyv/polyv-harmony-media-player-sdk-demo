import { isPortrait } from '../../../../utils/PLVDisplayUtils'
import { PLVOrientationManager } from '../../../../utils/PLVOrientationManager'

@Component
export struct PLVMediaPlayerCastToggleOrientationButton {
  build() {
    Image($r('app.media.plv_media_player_cast_toggle_orientation_button'))
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        if (isPortrait()) {
          PLVOrientationManager.getInstance().requestOrientation('land')
        } else {
          PLVOrientationManager.getInstance().requestOrientation('port')
        }
      })
  }
}