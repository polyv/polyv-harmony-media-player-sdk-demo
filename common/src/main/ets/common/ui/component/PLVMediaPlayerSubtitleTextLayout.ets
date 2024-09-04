import { DependScope, MutableObserver } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'

@Component
export struct PLVMediaPlayerSubtitleTextLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  @State topSubtitleText: string | null = null
  @State topSubtitleFontColor: string = "#FFFFFF"
  @State topSubtitleBold: boolean = false
  @State topSubtitleItalic: boolean = false
  @State topSubtitleBackgroundColor: string = "#000000"
  @State bottomSubtitleText: string | null = null
  @State bottomSubtitleFontColor: string = "#FFFFFF"
  @State bottomSubtitleBold: boolean = false
  @State bottomSubtitleItalic: boolean = false
  @State bottomSubtitleBackgroundColor: string = "#000000"
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.topSubtitleFontColor = viewState.topSubtitleTextStyle.fontColor
      this.topSubtitleBold = viewState.topSubtitleTextStyle.isBold
      this.topSubtitleItalic = viewState.topSubtitleTextStyle.isItalic
      this.topSubtitleBackgroundColor = viewState.topSubtitleTextStyle.backgroundColor
      this.bottomSubtitleFontColor = viewState.bottomSubtitleTextStyle.fontColor
      this.bottomSubtitleBold = viewState.bottomSubtitleTextStyle.isBold
      this.bottomSubtitleItalic = viewState.bottomSubtitleTextStyle.isItalic
      this.bottomSubtitleBackgroundColor = viewState.bottomSubtitleTextStyle.backgroundColor
    }).pushTo(this.observers)

    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.topSubtitleText = viewState.subtitleTexts[0]?.text ?? null
      this.bottomSubtitleText = viewState.subtitleTexts[1]?.text ?? null
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      if (this.topSubtitleText !== null) {
        Text(this.topSubtitleText)
          .fontColor(this.topSubtitleFontColor)
          .fontWeight(this.topSubtitleBold ? FontWeight.Bold : FontWeight.Normal)
          .fontStyle(this.topSubtitleItalic ? FontStyle.Italic : FontStyle.Normal)
          .backgroundColor(this.topSubtitleBackgroundColor)
          .textAlign(TextAlign.Center)
      }
      if (this.bottomSubtitleText !== null) {
        Text(this.bottomSubtitleText)
          .fontColor(this.bottomSubtitleFontColor)
          .fontWeight(this.bottomSubtitleBold ? FontWeight.Bold : FontWeight.Normal)
          .fontStyle(this.bottomSubtitleItalic ? FontStyle.Italic : FontStyle.Normal)
          .backgroundColor(this.bottomSubtitleBackgroundColor)
          .textAlign(TextAlign.Center)
      }
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}