import {
  BaseDanmaku,
  BaseDanmakuParser,
  Callback,
  DANMAKU_STYLE_STROKEN,
  DanmakuContext,
  Danmakus,
  DanmakuTimer,
  DanmakuView,
  IDanmakus
} from '@ohos/danmakuflamemaster';
import {
  DependScope,
  extendArray,
  extendNumber,
  MutableObserver,
  runCatching
} from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerDanmuData, PLVMediaPlayerDanmuMode } from '@polyvharmony/media-player-sdk-addon-business';
import { PLVMPDanmuViewModel } from '../../../modules/danmu/viewmodel/PLVMPDanmuViewModel';
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel';
import { DanmakuFlameMasterExtends } from './hook-danmaku-flame-master';

@Component
export struct PLVMediaPlayerDanmuLayout {
  @Consume dependScope: DependScope
  private readonly mediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private readonly danmuViewModel = this.dependScope.get(PLVMPDanmuViewModel)
  @State private readonly danmuModel: DanmakuView.Model = new DanmakuView.Model()
  private danmuList: PLVMediaPlayerDanmuData[] = []
  private lastDanmuProgress: number | undefined = undefined
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.danmuViewModel.danmuList.observe(it => this.danmuList = it)
      .pushTo(this.observers)

    this.danmuViewModel.onDanmuListRefresh.observe((danmuList) => {
      this.danmuModel.removeAllDanmakus(true)
      this.danmuModel.removeAllLiveDanmakus()
      this.danmuList = danmuList
    }).pushTo(this.observers)

    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      const progress = viewState.currentProgress
      const lastProgress = this.lastDanmuProgress
      if (lastProgress !== undefined) {
        this.addDanmuInRange(extendNumber(lastProgress).coerceAtLeast_ext(progress - 2000), progress)
      }
      this.lastDanmuProgress = progress
    }).pushTo(this.observers)

    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      runCatching(() => {
        const isPlaying = viewState.isPlaying
        const isDanmuPlaying = !this.danmuModel.isPaused()
        if (isPlaying !== isDanmuPlaying) {
          if (isPlaying) {
            this.danmuModel.resume()
          } else {
            this.danmuModel.pause()
          }
        }
      })
    }).pushTo(this.observers)

    this.mediaViewModel.onSeekCompleteEvent.observe(() => {
      runCatching(() => {
        this.danmuModel.removeAllDanmakus(true)
        this.danmuModel.removeAllLiveDanmakus()
      })
      this.lastDanmuProgress = undefined
    }).pushTo(this.observers)
  }

  build() {
    Stack() {
      DanmakuView({
        model: this.danmuModel
      })
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.prepareDanmuModel()
    })
    .onAreaChange((oldArea, newArea) => {
      runCatching(() => {
        this.danmuModel.setWidth(vp2px(newArea.width as number))
        this.danmuModel.setHeight(vp2px(newArea.height as number))
      })
    })
  }

  private prepareDanmuModel() {
    const danmuModel = this.danmuModel;

    class DanmakuCallback implements Callback {
      prepared(): void {
        runCatching(() => {
          danmuModel.start()
        })
      }

      updateTimer(timer: DanmakuTimer): void {
      }

      danmakuShown(danmaku: BaseDanmaku): void {
      }

      drawingFinished(): void {
      }
    }

    class DanmakuParser extends BaseDanmakuParser {
      protected parse(): IDanmakus {
        return new Danmakus({})
      }
    }

    runCatching(() => {
      const maxLinesPair: Map<number, number> = new Map();
      maxLinesPair.set(BaseDanmaku.TYPE_SCROLL_RL, 6);
      maxLinesPair.set(BaseDanmaku.TYPE_FIX_TOP, 6);
      maxLinesPair.set(BaseDanmaku.TYPE_FIX_BOTTOM, 2);
      const overlappingEnablePair: Map<number, boolean> = new Map();
      overlappingEnablePair.set(BaseDanmaku.TYPE_SCROLL_RL, true);
      const danmuContext = DanmakuContext.create()
        .setDanmakuStyle(DANMAKU_STYLE_STROKEN, 2)
        .setDuplicateMergingEnabled(false)
        .setScrollSpeedFactor(1.6)
        .setScaleTextSize(1.3)
        .setMaximumLines(maxLinesPair)
        .preventOverlapping(overlappingEnablePair)
      this.danmuModel.setCallback(new DanmakuCallback())
      this.danmuModel.prepare(new DanmakuParser(), danmuContext)
    })
  }

  private addDanmuInRange(min: number, max: number) {
    if (min >= max) {
      return
    }
    extendArray(this.danmuList)
      .filter(it => {
        const time = it.timestamp?.toMillis() ?? 0
        return min <= time && time < max
      })
      .sortBy_ext(it => it.timestamp?.toMillis() ?? 0)
      .forEach(it => {
        this.addDanmu(it)
      })
  }

  private addDanmu(danmu: PLVMediaPlayerDanmuData) {
    const content = danmu.content
    if (!content) {
      return
    }
    let type = BaseDanmaku.TYPE_SCROLL_RL
    switch (danmu.mode?.text) {
      case PLVMediaPlayerDanmuMode.ROLL_RIGHT_TO_LEFT.text:
        type = BaseDanmaku.TYPE_SCROLL_RL;
        break;
      case PLVMediaPlayerDanmuMode.FIX_TOP.text:
        type = BaseDanmaku.TYPE_FIX_TOP;
        break;
      case PLVMediaPlayerDanmuMode.FIX_BOTTOM.text:
        type = BaseDanmaku.TYPE_FIX_BOTTOM;
        break;
      default:
        type = BaseDanmaku.TYPE_SCROLL_RL;
        break;
    }
    runCatching(() => {
      const danmaku = this.danmuModel.getConfig().mDanmakuFactory.createDanmaku(type)
      danmaku.text = content
      danmaku.isLive = true
      danmaku.setTime(this.danmuModel.getCurrentTime())
      danmaku.priority = 0
      danmaku.textSize = vp2px(danmu.size ?? 16)
      danmaku.textColor = danmu.color ?? 0xFFFFFFFF
      danmaku.textShadowColor = danmu.color == 0xFF000000 ? 0xFFFFFFFF : 0xFF000000
      DanmakuFlameMasterExtends.fixBottomDanmakuNotVisible(danmaku)
      this.danmuModel.addDanmaku(danmaku)
      DanmakuFlameMasterExtends.fixDanmakuNotRenderWhenEmit(this.danmuModel)
    })
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    runCatching(() => this.danmuModel.release())
  }
}