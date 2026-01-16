import {
  DependScope,
  extendArray,
  MutableObserver,
  mutableStateOf,
  seconds,
  watchStates
} from '@polyvharmony/media-player-sdk'
import { PLVMediaPlayerKnowledgeViewModel } from '../../../modules/knowledge/PLVMediaPlayerKnowledgeViewModel'
import {
  PLVMediaPlayerKnowledgeVO_KnowledgePoint,
  PLVMediaPlayerKnowledgeVO_WordKey,
  PLVMediaPlayerKnowledgeVO_WordType
} from '../../../modules/knowledge/vo/PLVMediaPlayerKnowledgeVO'
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import {
  defineIds,
  parent,
  toBottomOf,
  toEndOf,
  toStartOf,
  usePadding
} from '../../../utils/arkts-no-everything'
import { formatDuration } from '../../../utils/PLVTimeUtils'
import { UIUtils } from '@kit.ArkUI'

@Component
export struct PLVMediaPlayerKnowledgeLayout {
  @Consume dependScope: DependScope
  private readonly mediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private readonly controllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private readonly knowledgeViewModel = this.dependScope.get(PLVMediaPlayerKnowledgeViewModel)
  private readonly stateSelectedWordType = mutableStateOf<PLVMediaPlayerKnowledgeVO_WordType | undefined>()
  private readonly stateSelectedWordKey = mutableStateOf<PLVMediaPlayerKnowledgeVO_WordKey | undefined>()
  @State private isVisible: boolean = false
  @State private wordTypes: PLVMediaPlayerKnowledgeVO_WordType[] = []
  @State private selectedWordType: PLVMediaPlayerKnowledgeVO_WordType | undefined = undefined
  @State private wordKeys: PLVMediaPlayerKnowledgeVO_WordKey[] = []
  @State private selectedWordKey: PLVMediaPlayerKnowledgeVO_WordKey | undefined = undefined
  @State private knowledgePoints: PLVMediaPlayerKnowledgeVO_KnowledgePoint[] = []
  @State private selectedKnowledgePoint: PLVMediaPlayerKnowledgeVO_KnowledgePoint | undefined = undefined
  @State private isFullscreenStyle: boolean = false
  private readonly ids = defineIds(
    'plv_media_player_knowledge_word_type_layout',
    'plv_media_player_knowledge_close_btn',
    'plv_media_player_knowledge_word_type_text',
    'plv_media_player_knowledge_word_key_layout',
    'plv_media_player_knowledge_point_layout',
  )
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.knowledgeViewModel.knowledgeData.observe((vo) => {
      this.isFullscreenStyle = vo.fullScreenStyle ?? false
      this.wordTypes = vo?.wordTypes ?? []
      if (!this.wordTypes.includes(this.selectedWordType ?? {})) {
        this.stateSelectedWordType.setValue(this.wordTypes[0])
        this.stateSelectedWordKey.setValue(this.wordTypes[0]?.wordKeys?.[0])
      }
    }).pushTo(this.observers)
    watchStates(() => {
      this.selectedWordType = this.stateSelectedWordType.value
      this.wordKeys = this.selectedWordType?.wordKeys ?? []
    }).pushTo(this.observers)
    watchStates(() => {
      this.selectedWordKey = this.stateSelectedWordKey.value
      this.knowledgePoints = this.selectedWordKey?.knowledgePoints ?? []
    }).pushTo(this.observers)
    watchStates(() => {
      const controllerViewState = this.controllerViewModel.mediaControllerViewState.value
      this.isVisible = extendArray(controllerViewState?.floatActionLayouts ?? []).lastOrNull_ext() === 'knowledge'
    }).pushTo(this.observers)
  }

  build() {
    Stack() {
      RelativeContainer() {
        RelativeContainer() {
          List() {
            ForEach(
              this.wordTypes,
              (wordType: PLVMediaPlayerKnowledgeVO_WordType) => {
                ListItem() {
                  Stack() {
                    Text(wordType.name)
                      .id(this.ids.plv_media_player_knowledge_word_type_text)
                      .height('100%')
                      .textAlign(TextAlign.Center)
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                      .padding(usePadding({
                        horizontal: 10
                      }))
                      .border({
                        color: this.isSelectedWordType(wordType) ? '#3990FF' : Color.Transparent,
                        width: {
                          bottom: 2,
                          top: 0,
                          left: 0,
                          right: 0
                        },
                        style: BorderStyle.Solid
                      })
                  }
                  .height('100%')
                  .padding(usePadding({
                    horizontal: 10
                  }))
                  .onClick(() => {
                    this.stateSelectedWordType.setValue(wordType)
                  })
                }
              }
            )
          }
          .height('100%')
          .listDirection(Axis.Horizontal)
          .alignRules({
            left: toStartOf(parent),
            right: toStartOf(this.ids.plv_media_player_knowledge_close_btn)
          })

          Image($r('app.media.plv_media_player_knowledge_close_icon'))
            .id(this.ids.plv_media_player_knowledge_close_btn)
            .width(48)
            .height(48)
            .padding(18)
            .alignRules({
              right: toEndOf(parent)
            })
            .onClick(() => {
              this.close()
            })
        }
        .id(this.ids.plv_media_player_knowledge_word_type_layout)
        .width('100%')
        .height(48)
        .backgroundColor('#0AFFFFFF')

        Stack() {
          List() {
            ForEach(
              this.wordKeys,
              (wordKey: PLVMediaPlayerKnowledgeVO_WordKey) => {
                ListItem() {
                  Stack() {
                    Row() {
                      Text(wordKey.name)
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .maxLines(1)
                        .textOverflow({
                          overflow: TextOverflow.Ellipsis
                        })
                        .ellipsisMode(EllipsisMode.END)

                      Blank()

                      Text(`(${wordKey.knowledgePoints?.length ?? 0})`)
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                    }
                    .width('100%')
                    .height('100%')
                    .alignItems(VerticalAlign.Center)
                    .padding(usePadding({
                      horizontal: 32
                    }))
                    .opacity(this.isSelectedWordKey(wordKey) ? 1 : 0.6)

                    Divider()
                      .width('100%')
                      .height(1)
                      .color('#14FFFFFF')
                      .visibility(this.isSelectedWordKey(wordKey) ? Visibility.None : Visibility.Visible)
                  }
                  .height(48)
                  .alignContent(Alignment.Bottom)
                  .backgroundColor(this.isSelectedWordKey(wordKey) ? '#14FFFFFF' : Color.Transparent)
                  .onClick(() => {
                    this.stateSelectedWordKey.setValue(wordKey)
                  })
                }
              }
            )
          }
          .width('100%')
          .height('100%')
        }
        .id(this.ids.plv_media_player_knowledge_word_key_layout)
        .width(240)
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_knowledge_word_type_layout),
          bottom: toBottomOf(parent)
        })

        Stack() {
          List() {
            ForEach(
              this.knowledgePoints,
              (knowledgePoint: PLVMediaPlayerKnowledgeVO_KnowledgePoint) => {
                ListItem() {
                  Row() {
                    Image(this.isSelectedKnowledgePoint(knowledgePoint) ? $r('app.media.plv_media_player_knowledge_selected_icon') : $r('app.media.plv_media_player_knowledge_unselected_icon'))
                      .width(24)
                      .height(24)
                      .margin({
                        left: 23
                      })

                    if (this.isFullscreenStyle) {
                      Text(knowledgePoint.name)
                        .fontSize(14)
                        .fontColor(this.isSelectedKnowledgePoint(knowledgePoint) ? '#3990FF' : '#CCFFFFFF')
                        .maxLines(1)
                        .textOverflow({
                          overflow: TextOverflow.Ellipsis
                        })
                        .ellipsisMode(EllipsisMode.END)
                        .margin({
                          left: 15
                        })
                    }

                    Blank()

                    Text(formatDuration((knowledgePoint.time ?? 0) * 1000))
                      .fontSize(14)
                      .fontColor(this.isSelectedKnowledgePoint(knowledgePoint) ? '#3990FF' : '#99FFFFFF')
                      .margin({
                        right: 32
                      })
                  }
                  .width('100%')
                  .height(48)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    this.selectedKnowledgePoint = knowledgePoint
                    this.mediaViewModel.seekTo(seconds(knowledgePoint.time ?? 0).toMillis())
                  })
                }
              }
            )
          }
          .width('100%')
          .height('100%')
        }
        .id(this.ids.plv_media_player_knowledge_point_layout)
        .backgroundColor('#14FFFFFF')
        .alignRules({
          top: toBottomOf(this.ids.plv_media_player_knowledge_word_type_layout),
          left: toEndOf(this.ids.plv_media_player_knowledge_word_key_layout),
          right: toEndOf(parent),
          bottom: toBottomOf(parent)
        })
      }
      .width(this.isFullscreenStyle ? '100%' : 380)
      .height('100%')
      .backgroundColor('#222326')
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.End)
    .visibility(this.isVisible ? Visibility.Visible : Visibility.Hidden)
    .onClick(() => {
      this.close()
    })
  }

  private close() {
    this.controllerViewModel.popFloatActionLayout()
  }

  private isSelectedWordType(wordType: PLVMediaPlayerKnowledgeVO_WordType) {
    return UIUtils.getTarget(this.selectedWordType) === wordType
  }

  private isSelectedWordKey(wordKey: PLVMediaPlayerKnowledgeVO_WordKey) {
    return UIUtils.getTarget(this.selectedWordKey) === wordKey
  }

  private isSelectedKnowledgePoint(knowledgePoint: PLVMediaPlayerKnowledgeVO_KnowledgePoint) {
    return UIUtils.getTarget(this.selectedKnowledgePoint) === knowledgePoint
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}