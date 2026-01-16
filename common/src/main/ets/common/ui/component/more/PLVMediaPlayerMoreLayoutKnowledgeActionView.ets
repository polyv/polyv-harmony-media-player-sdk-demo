import { DependScope, MutableObserver, watchStates } from '@polyvharmony/media-player-sdk'
import { PLVMediaPlayerKnowledgeViewModel } from '../../../modules/knowledge/PLVMediaPlayerKnowledgeViewModel'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'

@Component
export struct PLVMediaPlayerMoreLayoutKnowledgeActionView {
  @Consume dependScope: DependScope
  iconResource: Resource = $r('app.media.plv_media_player_more_knowledge_action_icon')
  textFontColor: string = '#CCFFFFFF'
  private readonly controllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private readonly knowledgeViewModel = this.dependScope.get(PLVMediaPlayerKnowledgeViewModel)
  @State private isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    watchStates(async () => {
      this.isVisible = this.knowledgeViewModel.knowledgeData.value !== undefined
    }).pushTo(this.observers)
  }

  build() {
    if (this.isVisible) {
      Column() {
        Image(this.iconResource)
          .width(36)
          .height(36)
          .padding(4)
          .objectFit(ImageFit.Contain)

        Text($r('app.string.plv_media_player_ui_component_knowledge_hint_text'))
          .margin({
            top: 4
          })
          .fontColor(this.textFontColor)
          .fontSize(12)
      }
      .onClick(() => {
        this.controllerViewModel.pushFloatActionLayout('knowledge')
      })
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}