import { DependScope, MutableObserver, seconds } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMarqueeAnimateSettingVO, PLVMarqueeAnimateType } from './marquee/model/PLVMarqueeAnimateSettingVO'
import { PLVMarqueeModel, PLVMarqueePlayingState } from './marquee/model/PLVMarqueeModel'
import { PLVMarqueeTextSettingVO } from './marquee/model/PLVMarqueeTextSettingVO'
import { PLVMarqueeView } from './marquee/PLVMarqueeView'

@Component
export struct PLVMediaPlayerMarqueeLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private marqueeModel: PLVMarqueeModel = this.createMarqueeModel()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.marqueeModel.setPlayingState(viewState.isPlaying ? PLVMarqueePlayingState.PLAY : PLVMarqueePlayingState.PAUSE)
    }).pushTo(this.observers)
  }

  private createMarqueeModel(): PLVMarqueeModel {
    return new PLVMarqueeModel(
      new PLVMarqueeAnimateSettingVO()
        .setAnimateType(PLVMarqueeAnimateType.ROLL_DOUBLE_MARQUEE)
        .setRollTime(seconds(20))
        .setRollInterval(seconds(3))
        .setTweenTime(seconds(2))
        .setTweenInterval(seconds(2))
        .setHiddenWhenPause(false)
        .setAlwaysShowWhenRun(false),
      new PLVMarqueeTextSettingVO()
        .setContent("播放器跑马灯 MediaPlayerMarquee")
        .setFontColor('#FF0000')
        .setFontSize(40)
        .setShadow(true)
        .setShadowColor('#000000')
        .setShadowOffsetX(2)
        .setShadowOffsetY(2)
        .setShadowRadius(4),
      new PLVMarqueeTextSettingVO()
        .setContent("MediaPlayerMarquee")
        .setFontColor('#05000000')
        .setFontSize(24)
        .setShadow(true)
        .setShadowColor('#05000000')
        .setShadowOffsetX(2)
        .setShadowOffsetY(2)
        .setShadowRadius(4)
    )
  }

  build() {
    PLVMarqueeView({
      model: this.marqueeModel
    })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}