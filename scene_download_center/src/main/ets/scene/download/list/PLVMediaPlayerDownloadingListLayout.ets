import { bytes, lateInit, MutableObserver, State as PLVState } from '@polyvharmony/media-player-sdk';
import {
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusWaiting
} from '@polyvharmony/media-player-sdk-addon-cache-down';
import {
  createId,
  downloadStatusText,
  formatDuration,
  parent,
  PLVMPDownloadListItemViewState,
  PLVMPDownloadListViewModel,
  readFileAsPixelMap,
  toBottomOf,
  toEndOf,
  toStartOf,
  toTopOf,
  usePadding
} from 'media-player-common';

@Component
export struct PLVMediaPlayerDownloadingListLayout {
  private readonly downloadListViewModel: PLVMPDownloadListViewModel = PLVMPDownloadListViewModel.getInstance();
  @State downloadingList: PLVState<PLVMPDownloadListItemViewState>[] = []
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.downloadListViewModel.downloadingList.observe((viewState) => {
      this.downloadingList = viewState.list
    }).pushTo(this.observers)
  }

  build() {
    List() {
      ForEach(
        this.downloadingList,
        (state: PLVState<PLVMPDownloadListItemViewState>) => {
          ListItem() {
            DownloadingListItem({
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
struct DownloadingListItem {
  viewState: PLVState<PLVMPDownloadListItemViewState> = lateInit()
  private observers: MutableObserver[] = []
  @State coverImage: string | null = null
  @State coverImagePixelMap: PixelMap | null = null
  @State duration: string = ""
  @State title: string = ""
  @State bitRateWithSize: string = ""
  @State progress: number = 0
  @State isClickToDownload: boolean = true
  @State downloadStatusText: string = ""
  // <editor-fold defaultstate="collapsed" desc="ids">
  private readonly plv_media_player_download_item_cover_image: string = createId()
  private readonly plv_media_player_download_item_duration: string = createId()
  private readonly plv_media_player_download_item_title: string = createId()
  private readonly plv_media_player_download_item_bit_rate_with_size: string = createId()
  private readonly plv_media_player_download_item_progress_bar: string = createId()
  private readonly plv_media_player_download_item_download_icon: string = createId()
  private readonly plv_media_player_download_item_download_status: string = createId()

  // </editor-fold>

  aboutToAppear(): void {
    this.viewState.observe((viewState) => {
      if (this.coverImage != viewState.coverImage && viewState.coverImage) {
        readFileAsPixelMap(viewState.coverImage).then((pixelMap) => this.coverImagePixelMap = pixelMap)
      }
      this.coverImage = viewState.coverImage
      this.duration = formatDuration(viewState.duration.toMillis(Math.round))
      this.title = viewState.title
      const size = bytes(viewState.fileSize).toSuitableUnit()
      this.bitRateWithSize = `${viewState.bitRate.name}:${size.value.toFixed(1)} ${size.unit.abbr}`
      this.progress = viewState.progress * 100
      this.isClickToDownload = viewState.downloadStatus.canStartDownload()
      const progressText = `${this.progress.toFixed(1)}%`
      const downloadSpeed = bytes(viewState.downloadBytesPerSecond).toSuitableUnit()
      const downloadSpeedText = `(${downloadSpeed.value.toFixed(1)} ${downloadSpeed.unit.abbr}/s)`
      if (viewState.downloadStatus instanceof PLVMediaDownloadStatusDownloading) {
        this.downloadStatusText = `${downloadStatusText(viewState.downloadStatus)} ${progressText} ${downloadSpeedText}`
      } else if (viewState.downloadStatus instanceof PLVMediaDownloadStatusWaiting) {
        this.downloadStatusText = `${downloadStatusText(viewState.downloadStatus)} ${progressText}`
      } else {
        this.downloadStatusText = downloadStatusText(viewState.downloadStatus)
      }
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

          Text(this.title)
            .id(this.plv_media_player_download_item_title)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .alignRules({
              top: toTopOf(this.plv_media_player_download_item_cover_image),
              start: toEndOf(this.plv_media_player_download_item_cover_image),
              end: toStartOf(this.plv_media_player_download_item_bit_rate_with_size)
            })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)
            .margin(usePadding({
              horizontal: 8
            }))

          Text(this.bitRateWithSize)
            .id(this.plv_media_player_download_item_bit_rate_with_size)
            .fontSize(12)
            .fontColor('#66FFFFFF')
            .alignRules({
              top: toTopOf(parent),
              end: toEndOf(parent)
            })
            .margin({
              top: 2
            })

          Progress({
            value: this.progress,
            total: 100,
            type: ProgressType.Linear
          })
            .id(this.plv_media_player_download_item_progress_bar)
            .color('#3F76FC')
            .backgroundColor('#33FFFFFF')
            .style({
              strokeRadius: 2,
              strokeWidth: 3
            })
            .borderRadius(2)
            .alignRules({
              bottom: toTopOf(this.plv_media_player_download_item_download_status),
              start: toEndOf(this.plv_media_player_download_item_cover_image),
              end: toStartOf(this.plv_media_player_download_item_download_icon)
            })
            .margin(usePadding({
              horizontal: 8,
              right: 12,
              bottom: 8
            }))

          Image(this.isClickToDownload ? $r('app.media.plv_media_player_download_item_download_icon_to_start') : $r('app.media.plv_media_player_download_item_download_icon_to_pause'))
            .id(this.plv_media_player_download_item_download_icon)
            .width(20)
            .height(20)
            .alignRules({
              end: toEndOf(parent),
              top: toBottomOf(this.plv_media_player_download_item_bit_rate_with_size)
            })
            .margin({
              top: 8
            })
            .onClick(() => {
              if (this.isClickToDownload) {
                this.viewState.value?.startDownload()
              } else {
                this.viewState.value?.pauseDownload()
              }
            })

          Text(this.downloadStatusText)
            .id(this.plv_media_player_download_item_download_status)
            .fontSize(12)
            .fontColor('#66FFFFFF')
            .alignRules({
              start: toEndOf(this.plv_media_player_download_item_cover_image),
              bottom: toBottomOf(this.plv_media_player_download_item_cover_image)
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

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}