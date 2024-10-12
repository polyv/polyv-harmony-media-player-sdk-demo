import {
  DependScope,
  DerivedState,
  MutableObserver,
  MutableState,
  PLVMediaPlayerAppContext
} from '@polyvharmony/media-player-sdk';
import {
  createId,
  parent,
  PLVMPDownloadListViewModel,
  PLVMPPageControlViewModel,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toMiddleOf,
  toStartOf,
  toTopOf
} from 'media-player-common';
import { PLVMediaPlayerDownloadCompletedListLayout } from './list/PLVMediaPlayerDownloadCompletedListLayout';
import { PLVMediaPlayerDownloadingListLayout } from './list/PLVMediaPlayerDownloadingListLayout';

@Component
export struct PLVMediaPlayerDownloadCenterLayout {
  defaultTabIndex: number = 0
  @Consume pageDependScope: DependScope
  private readonly pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  private readonly downloadListViewModel: PLVMPDownloadListViewModel = PLVMPDownloadListViewModel.getInstance();
  private readonly currentSelectTab: MutableState<number> = new MutableState();
  private readonly tabSwiperController: SwiperController = new SwiperController();
  @State currentSelectTabState: number = 0
  @State downloadCompletedCountText: string = ""
  @State downloadingCountText: string = ""
  @State downloadListEmptyHintVisible: boolean = false
  private observers: MutableObserver[] = []
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_download_center_background: string = createId()
  private readonly plv_media_player_download_back_icon: string = createId()
  private readonly plv_media_player_download_title: string = createId()
  private readonly plv_media_player_download_tab_layout: string = createId()
  private readonly plv_media_player_download_tab_swiper: string = createId()
  private readonly plv_media_player_download_list_is_empty_layout: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.downloadListViewModel.downloadedList.observe((viewState) => {
      const count = viewState.list.length
      const countText = count > 0 ? `(${count})` : ""
      this.downloadCompletedCountText = PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_completed")) + countText
    }).pushTo(this.observers)

    this.downloadListViewModel.downloadingList.observe((viewState) => {
      const count = viewState.list.length
      const countText = count > 0 ? `(${count})` : ""
      this.downloadingCountText = PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_downloading")) + countText
    }).pushTo(this.observers)

    this.currentSelectTab.setValue(this.defaultTabIndex)
    this.currentSelectTab.observe((index) => {
      this.tabSwiperController.changeIndex(index, true)
      this.currentSelectTabState = index
    }).pushTo(this.observers)

    const downloadListEmptyState = new DerivedState(() => {
      if (this.currentSelectTab.value === 0) {
        return (this.downloadListViewModel.downloadedList.value?.list?.length ?? 0) === 0
      } else {
        return (this.downloadListViewModel.downloadingList.value?.list?.length ?? 0) === 0
      }
    })
    downloadListEmptyState.observe((listEmpty) => {
      this.downloadListEmptyHintVisible = listEmpty
    }).pushTo(this.observers)
  }

  build() {
    RelativeContainer() {
      Stack() {
      }
      .id(this.plv_media_player_download_center_background)
      .width('100%')
      .height('100%')
      .backgroundColor('#172449')
      .expandSafeArea()

      Image($r('app.media.plv_media_player_back_icon'))
        .id(this.plv_media_player_download_back_icon)
        .width(28)
        .height(28)
        .margin({
          left: 16,
          top: 8
        })
        .alignRules({
          top: toTopOf(parent),
          start: toStartOf(parent)
        })
        .onClick(() => {
          const navPathStack: NavPathStack | undefined = this.pageControlViewModel.navPathStack
          navPathStack?.pop()
        })

      Text($r('app.string.plv_media_player_download_center_text'))
        .id(this.plv_media_player_download_title)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .alignRules({
          start: toEndOf(this.plv_media_player_download_back_icon),
          center: toCenterOf(this.plv_media_player_download_back_icon)
        })

      Row({ space: 20 }) {
        Column() {
          Text(this.downloadCompletedCountText)
            .fontColor(this.currentSelectTabState == 0 ? "#FFFFFF" : "#99FFFFFF")
            .fontSize(16)

          Shape()
            .width(20)
            .height(2)
            .borderRadius(2)
            .backgroundColor("#3F76FC")
            .margin({
              top: 6
            })
            .visibility(this.currentSelectTabState == 0 ? Visibility.Visible : Visibility.Hidden)
        }
        .padding(12)
        .onClick(() => this.currentSelectTab.value = 0)

        Column() {
          Text(this.downloadingCountText)
            .fontColor(this.currentSelectTabState == 1 ? "#FFFFFF" : "#99FFFFFF")
            .fontSize(16)

          Shape()
            .width(20)
            .height(2)
            .borderRadius(2)
            .backgroundColor("#3F76FC")
            .margin({
              top: 6
            })
            .visibility(this.currentSelectTabState == 1 ? Visibility.Visible : Visibility.Hidden)
        }
        .padding(12)
        .onClick(() => this.currentSelectTab.value = 1)
      }
      .id(this.plv_media_player_download_tab_layout)
      .margin({
        left: 16,
        top: 18
      })
      .alignRules({
        start: toStartOf(parent),
        top: toBottomOf(this.plv_media_player_download_back_icon)
      })

      Swiper(this.tabSwiperController) {
        PLVMediaPlayerDownloadCompletedListLayout()
          .width('100%')
          .height('100%')

        PLVMediaPlayerDownloadingListLayout()
          .width('100%')
          .height('100%')
      }
      .indicator(false)
      .autoPlay(false)
      .loop(false)
      .disableSwipe(true)
      .vertical(false)
      .id(this.plv_media_player_download_tab_swiper)
      .width('100%')
      .alignRules({
        top: toBottomOf(this.plv_media_player_download_tab_layout),
        bottom: toBottomOf(parent)
      })
      .margin({
        top: 6
      })
      .onAppear(() => {
        const index = this.currentSelectTab.value
        if (index !== undefined) {
          this.tabSwiperController.changeIndex(index, true)
        }
      })

      Column() {
        Image($r("app.media.plv_media_player_download_list_is_empty_icon"))
          .width(60)
          .height(60)

        Text($r("app.string.plv_media_player_download_center_list_is_empty"))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .margin({
            top: 12
          })
      }
      .id(this.plv_media_player_download_list_is_empty_layout)
      .visibility(this.downloadListEmptyHintVisible ? Visibility.Visible : Visibility.None)
      .alignRules({
        middle: toMiddleOf(parent),
        top: toTopOf(parent)
      })
      .margin({
        top: 280
      })

    }

  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}