import { MutableState, OnBackPressHandler } from '@polyvharmony/media-player-sdk';
import { PLVComponentLifecycle } from '../../../utils/PLVComponentLifecycle';

export class PLVMPPageControlViewModel {

  // 只登记播放页，下载页不参与播放器所有权切换。
  private static playbackPages: PLVMPPageControlViewModel[] = []
  private static activePlaybackPage: PLVMPPageControlViewModel | undefined
  readonly playbackPageActive: MutableState<boolean> = new MutableState(true)

  activatePlaybackPage(): void {
    const pages = PLVMPPageControlViewModel.playbackPages
    if (!pages.includes(this)) {
      pages.push(this)
    }
    const previous = PLVMPPageControlViewModel.activePlaybackPage
    if (previous === this) {
      return
    }
    previous?.playbackPageActive.setValue(false)
    PLVMPPageControlViewModel.activePlaybackPage = this
    this.playbackPageActive.setValue(true)
  }

  releasePlaybackPage(): void {
    const pages = PLVMPPageControlViewModel.playbackPages
    const index = pages.indexOf(this)
    if (index < 0) {
      return
    }
    pages.splice(index, 1)
    this.playbackPageActive.setValue(false)
    if (PLVMPPageControlViewModel.activePlaybackPage === this) {
      PLVMPPageControlViewModel.activePlaybackPage = undefined
      // 新播放页退出后，恢复导航栈中仍保留的上一播放页（中间可以隔着下载页）。
      pages[pages.length - 1]?.activatePlaybackPage()
    }
  }


  readonly currentItemIndex: MutableState<number> = new MutableState(0)
  readonly pageLifecycle: PLVComponentLifecycle = new PLVComponentLifecycle()
  readonly onBackPressHandler = new OnBackPressHandler()
  navPathStack?: any | undefined = undefined

  onCurrentItemChanged(currentIndex: number) {
    this.currentItemIndex.value = currentIndex
  }

}

export const ON_BACK_PRESS_PRIORITY_ORIENTATION = 10

export const ON_BACK_PRESS_PRIORITY_TEXT_INPUT = 100