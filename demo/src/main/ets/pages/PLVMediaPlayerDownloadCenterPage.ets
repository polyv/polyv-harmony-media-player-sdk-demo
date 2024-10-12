import { PLVMediaPlayerDownloadCenterPageParam, PLVMediaPlayerScenes } from 'media-player-common'
import { PLVMediaPlayerDownloadCenterLayout } from 'scene_download_center'

@Component
export struct PLVMediaPlayerDownloadCenterPage {
  @Consume navPathStack: NavPathStack
  private param: PLVMediaPlayerDownloadCenterPageParam = this.navPathStack.getParamByName(PLVMediaPlayerScenes.DOWNLOAD_CENTER.name)[0] as PLVMediaPlayerDownloadCenterPageParam

  build() {
    PLVMediaPlayerDownloadCenterLayout({
      defaultTabIndex: this.param.defaultTabIndex
    })
  }
}