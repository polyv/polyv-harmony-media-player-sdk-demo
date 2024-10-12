import { bytes, DependScope, lateInit, MutableObserver, State as PLVState } from '@polyvharmony/media-player-sdk';
import { PLVMediaDownloader } from '@polyvharmony/media-player-sdk-addon-cache-down';
import {
  createId,
  formatDuration,
  parent,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
  PLVMPDownloadListItemViewState,
  PLVMPDownloadListViewModel,
  PLVMPPageControlViewModel,
  readFileAsPixelMap,
  toBottomOf,
  toCenterOf,
  toEndOf,
  toStartOf,
  usePadding
} from 'media-player-common';

@Component
export struct PLVMediaPlayerDownloadCompletedListLayout {
  private readonly downloadListViewModel: PLVMPDownloadListViewModel = PLVMPDownloadListViewModel.getInstance();
  @State downloadedList: PLVState<PLVMPDownloadListItemViewState>[] = []
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.downloadListViewModel.downloadedList.observe((viewState) => {
      this.downloadedList = viewState.list
    }).pushTo(this.observers)
  }

  build() {
    List() {
      ForEach(
        this.downloadedList,
        (state: PLVState<PLVMPDownloadListItemViewState>) => {
          ListItem() {
            DownloadCompletedListItem({
              viewState: state
            })
          }
        },
        (state: PLVState<PLVMPDownloadListItemViewState>) => state.value?.downloader?.inMemoryDownloaderUniqueId?.toString() ?? "null"
      )
    }
    .width('100%')
    .height('100%')
    .listDirection(Axis.Vertical)
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}

@Component
struct DownloadCompletedListItem {
  @Consume pageDependScope: DependScope
  private readonly pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  viewState: PLVState<PLVMPDownloadListItemViewState> = lateInit()
  private observers: MutableObserver[] = []
  private downloader: PLVMediaDownloader | null = null
  @State coverImage: string | null = null
  @State coverImagePixelMap: PixelMap | null = null
  @State duration: string = ""
  @State title: string = ""
  @State bitRateWithSize: string = ""
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_download_item_cover_image: string = createId()
  private readonly plv_media_player_download_item_duration: string = createId()
  private readonly plv_media_player_download_item_description_column: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.viewState.observe((viewState) => {
      this.downloader = viewState.downloader
      if (this.coverImage != viewState.coverImage && viewState.coverImage) {
        readFileAsPixelMap(viewState.coverImage).then((pixelMap) => this.coverImagePixelMap = pixelMap)
      }
      this.coverImage = viewState.coverImage
      this.duration = formatDuration(viewState.duration.toMillis(Math.round))
      this.title = viewState.title
      const size = bytes(viewState.fileSize).toSuitableUnit()
      this.bitRateWithSize = `${viewState.bitRate.name}:${size.value.toFixed(1)} ${size.unit.abbr}`
    }).pushTo(this.observers)
  }

  build() {
    Scroll() {
      Row() {
        RelativeContainer() {
          Image(this.coverImagePixelMap ?? $r("app.media.plv_media_player_download_item_default_cover_image"))
            .id(this.plv_media_player_download_item_cover_image)
            .width(104)
            .height(58)
            .borderRadius(4)
            .alignRules({
              start: toStartOf(parent)
            })
            .onClick(() => {
              this.gotoDownloadedSingleVideo()
            })

          Text(this.duration)
            .id(this.plv_media_player_download_item_duration)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .alignRules({
              end: toEndOf(this.plv_media_player_download_item_cover_image),
              bottom: toBottomOf(this.plv_media_player_download_item_cover_image)
            })
            .margin({
              right: 4,
              bottom: 4
            })

          Column() {
            Text(this.title)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .ellipsisMode(EllipsisMode.END)

            Text(this.bitRateWithSize)
              .fontSize(12)
              .fontColor('#66FFFFFF')
              .margin({
                top: 5
              })
          }
          .id(this.plv_media_player_download_item_description_column)
          .alignItems(HorizontalAlign.Start)
          .alignRules({
            start: toEndOf(this.plv_media_player_download_item_cover_image),
            end: toEndOf(parent),
            center: toCenterOf(this.plv_media_player_download_item_cover_image)
          })
          .margin({
            left: 8
          })

        }
        .width('100%')
        .height(70)
        .padding(usePadding({
          vertical: 6,
          horizontal: 16
        }))

        Text("删除")
          .width(100)
          .height(58)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .backgroundColor('#FF0000')
          .onClick(() => {
            this.viewState.value?.deleteDownload()
          })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  private gotoDownloadedSingleVideo() {
    const navPathStack: NavPathStack | undefined = this.pageControlViewModel.navPathStack
    if (this.downloader === null || navPathStack === undefined) {
      return
    }
    navPathStack.removeByName(PLVMediaPlayerScenes.SINGLE_VIDEO.name)
    navPathStack.removeByName(PLVMediaPlayerScenes.FEED_VIDEO.name)
    navPathStack.pushPath(new NavPathInfo(
      PLVMediaPlayerScenes.SINGLE_VIDEO.name,
      new PLVMediaPlayerSingleVideoPageParam(this.downloader.mediaResource, true)
    ))
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}