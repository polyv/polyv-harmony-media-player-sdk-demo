import { createDependScope, DependScope, lateInit } from '@polyvharmony/media-player-sdk'
import {
  commonPageModule,
  PLVAbilityContexts,
  PLVMediaPlayerDownloadCenterPageParam,
  PLVMediaPlayerFeedVideoPageParam,
  PLVMediaPlayerScenes,
  PLVMediaPlayerSingleVideoPageParam,
  PLVMPPageControlViewModel,
  whatever
} from 'media-player-common'
import { common } from '@kit.AbilityKit'
import { PLVMediaPlayerFeedVideoPage } from '../PLVMediaPlayerFeedVideoPage'
import { PLVMediaPlayerDownloadCenterPage } from '../PLVMediaPlayerDownloadCenterPage'
import { PLVMediaPlayerSingleVideoPage } from '../PLVMediaPlayerSingleVideoPage'

@Component
export struct PLVMediaPlayerNavigationPage {
  navigationName: string = lateInit()
  param: whatever = lateInit()
  @Consume navPathStack: NavPathStack
  @Provide pageDependScope: DependScope = createDependScope(commonPageModule)
  private pageControlViewModel: PLVMPPageControlViewModel = this.pageDependScope.get(PLVMPPageControlViewModel)

  navAboutToAppear(): void {
    PLVAbilityContexts.getInstance().registerContext(getContext(this) as common.UIAbilityContext)
    this.pageControlViewModel.navPathStack = this.navPathStack
    this.pageControlViewModel.pageLifecycle.onAboutToAppear()
  }

  navOnPageShow(): void {
    this.pageControlViewModel.pageLifecycle.onPageShow()
  }

  build() {
    NavDestination() {
      if (this.navigationName == PLVMediaPlayerScenes.SINGLE_VIDEO.name) {
        PLVMediaPlayerSingleVideoPage({
          param: this.param as PLVMediaPlayerSingleVideoPageParam
        })
      }
      if (this.navigationName == PLVMediaPlayerScenes.FEED_VIDEO.name) {
        PLVMediaPlayerFeedVideoPage({
          param: this.param as PLVMediaPlayerFeedVideoPageParam
        })
      }
      if (this.navigationName == PLVMediaPlayerScenes.DOWNLOAD_CENTER.name) {
        PLVMediaPlayerDownloadCenterPage({
          param: this.param as PLVMediaPlayerDownloadCenterPageParam
        })
      }
    }
    .hideTitleBar(true)
    .expandSafeArea()
    .onAppear(() => this.navAboutToAppear())
    .onShown(() => this.navOnPageShow())
    .onHidden(() => this.navOnPageHide())
    .onDisAppear(() => this.navAboutToDisappear())
    .onBackPressed(() => this.navOnBackPressed())
  }

  navOnBackPressed(): boolean {
    return this.pageControlViewModel.onBackPressHandler.onBackPress()
  }

  navOnPageHide(): void {
    this.pageControlViewModel.pageLifecycle.onPageHide()
  }

  navAboutToDisappear(): void {
    this.pageControlViewModel.pageLifecycle.onAboutToDisappear()
    PLVAbilityContexts.getInstance().unregisterContext(getContext(this) as common.UIAbilityContext)
  }
}