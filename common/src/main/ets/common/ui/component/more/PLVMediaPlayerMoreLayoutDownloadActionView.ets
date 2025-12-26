import { DependScope, MutableObserver, PLVMediaPlayerAppContext } from '@polyvharmony/media-player-sdk'
import {
  PLVMediaDownloadStatus,
  PLVMediaDownloadStatusCompleted,
  PLVMediaDownloadStatusDownloading,
  PLVMediaDownloadStatusError,
  PLVMediaDownloadStatusNotStarted,
  PLVMediaDownloadStatusPaused,
  PLVMediaDownloadStatusWaiting
} from '@polyvharmony/media-player-sdk-addon-cache-down'
import { PLVMPDownloadItemViewModel } from '../../../modules/download/single/viewmodel/PLVMPDownloadItemViewModel'
import { PLVMPPageControlViewModel } from '../../../modules/pagecontrol/viewmodel/PLVMPPageControlViewModel'
import { PLVMediaPlayerDownloadCenterPageParam, PLVMediaPlayerScenes } from '../../enums/PLVMediaPlayerScenes'

@Component
export struct PLVMediaPlayerMoreLayoutDownloadActionView {
  @Consume dependScope: DependScope
  @Consume pageDependScope: DependScope
  iconResource: Resource = $r("app.media.plv_media_player_more_download_action_icon_port")
  textFontColor: string = '#FFFFFF'
  private readonly downloadViewModel = this.dependScope.get(PLVMPDownloadItemViewModel)
  private readonly pageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)
  @State downloadStatusText: string = PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text"))
  @State isShowDownloadProgress: boolean = false
  @State downloadProgress: number = 0
  @State downloadProgressText: string = "0%"
  @State isVisible: boolean = false
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.downloadViewModel.downloadItem.observe((viewState) => {
      if (viewState === null) {
        return
      }
      this.downloadStatusText = downloadStatusText(viewState.status)
      this.isShowDownloadProgress = viewState.status instanceof PLVMediaDownloadStatusDownloading
        || viewState.status instanceof PLVMediaDownloadStatusWaiting;
      this.downloadProgress = Math.floor(viewState.progress * 100)
      this.downloadProgressText = `${this.downloadProgress}%`
      this.isVisible = viewState.isVisible
    }).pushTo(this.observers)
  }

  build() {
    Column() {
      if (!this.isShowDownloadProgress) {
        Image(this.iconResource)
          .width(36)
          .height(36)
          .draggable(false)
      }

      if (this.isShowDownloadProgress) {
        Stack() {
          Progress({
            value: this.downloadProgress,
            total: 100,
            type: ProgressType.Ring
          })
            .width(36)
            .height(36)
            .color('#3F76FC')
            .backgroundColor('#333F76FC')
            .style({
              strokeWidth: 3
            })

          Text(this.downloadProgressText)
            .fontColor('#3F76FC')
            .fontSize(12)
        }
      }

      Text(this.downloadStatusText)
        .fontColor(this.textFontColor)
        .fontSize(12)
        .margin({
          top: 4
        })
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture()
          .onAction(() => {
            const status = this.downloadViewModel.downloadItem.value?.status ?? PLVMediaDownloadStatusNotStarted.instance
            if (status instanceof PLVMediaDownloadStatusNotStarted
              || status instanceof PLVMediaDownloadStatusPaused
              || status instanceof PLVMediaDownloadStatusError) {
              this.downloadViewModel.startDownload()
            } else {
              this.gotoDownloadCenter()
            }
          }),
        LongPressGesture()
          .onAction(() => this.gotoDownloadCenter())
      )
    )
  }

  private gotoDownloadCenter() {
    const navPathStack: NavPathStack | undefined = this.pageControlViewModel.navPathStack
    if (navPathStack === undefined) {
      return
    }
    const status = this.downloadViewModel.downloadItem.value?.status ?? PLVMediaDownloadStatusNotStarted.instance
    let gotoDownloadingTab = false
    if (status instanceof PLVMediaDownloadStatusPaused
      || status instanceof PLVMediaDownloadStatusWaiting
      || status instanceof PLVMediaDownloadStatusDownloading
      || status instanceof PLVMediaDownloadStatusError) {
      gotoDownloadingTab = true
    }
    navPathStack.pushPath(new NavPathInfo(
      PLVMediaPlayerScenes.DOWNLOAD_CENTER.name,
      new PLVMediaPlayerDownloadCenterPageParam(gotoDownloadingTab ? 1 : 0)
    ))
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}

export function downloadStatusText(status: PLVMediaDownloadStatus): string {
  if (status instanceof PLVMediaDownloadStatusPaused) {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_paused"))
  } else if (status instanceof PLVMediaDownloadStatusDownloading) {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_downloading"))
  } else if (status instanceof PLVMediaDownloadStatusWaiting) {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_waiting"))
  } else if (status instanceof PLVMediaDownloadStatusCompleted) {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_completed"))
  } else if (status instanceof PLVMediaDownloadStatusError) {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text_failed"))
  } else {
    return PLVMediaPlayerAppContext.getString($r("app.string.plv_media_player_ui_component_download_text"))
  }
}