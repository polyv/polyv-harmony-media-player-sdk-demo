import { lateInit } from '@polyvharmony/media-player-sdk'
import { PLVMediaPlayerDownloadCenterPageParam } from 'media-player-common'
import { PLVMediaPlayerDownloadCenterLayout } from 'scene_download_center'

@Component
export struct PLVMediaPlayerDownloadCenterPage {
  param: PLVMediaPlayerDownloadCenterPageParam = lateInit()
  @Consume navPathStack: NavPathStack

  build() {
    PLVMediaPlayerDownloadCenterLayout({
      defaultTabIndex: this.param.defaultTabIndex
    })
  }
}