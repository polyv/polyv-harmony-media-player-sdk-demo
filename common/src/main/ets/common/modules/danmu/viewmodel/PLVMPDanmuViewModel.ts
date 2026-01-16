import {
  LifecycleAwareDependComponent,
  millis,
  MutableEvent,
  MutableObserver,
  mutableStateOf,
  runCatching
} from '@polyvharmony/media-player-sdk';
import { PLVMediaPlayerDanmuData, PLVMediaPlayerDanmuMode } from '@polyvharmony/media-player-sdk-addon-business';
import { PLVMPDanmuRepo } from '../model/PLVMPDanmuRepo';
import { PLVMPDanmuSize, PLVMPDanmuStyleViewState } from './viewstate/PLVMPDanmuStyleViewState';

export class PLVMPDanmuViewModel implements LifecycleAwareDependComponent {
  constructor(
    private readonly repo: PLVMPDanmuRepo
  ) {
    this.init()
  }

  readonly danmuStyle = mutableStateOf(new PLVMPDanmuStyleViewState())
  readonly danmuList = mutableStateOf<PLVMediaPlayerDanmuData[]>([])
  readonly inputLayoutVisible = mutableStateOf(false)
  readonly onDanmuListRefresh = new MutableEvent<PLVMediaPlayerDanmuData[]>()

  private observers: MutableObserver[] = []

  private init() {
    this.repo.mediaMediator.mediaResource.observe(async () => {
      const result = await runCatching(this.repo.danmuManager.loadDanmu())
      if (result.success) {
        this.danmuList.setValue(result.data)
        this.onDanmuListRefresh.setValue(result.data)
      }
    })
      .pushTo(this.observers)
  }

  async sendDanmu(content: string) {
    const progress = this.repo.mediaMediator.mediaPlayViewState.value?.currentProgress ?? 0
    const danmuData = new PLVMediaPlayerDanmuData()
    danmuData.content = content
    danmuData.timestamp = millis(progress)
    danmuData.color = this.danmuStyle.value?.color ?? 0xFFFFFFFF
    danmuData.size = (this.danmuStyle.value?.size ?? PLVMPDanmuSize.MEDIUM).value
    danmuData.mode = this.danmuStyle.value?.mode ?? PLVMediaPlayerDanmuMode.ROLL_RIGHT_TO_LEFT
    await this.repo.danmuManager.sendDanmu(danmuData)
    const newDanmus = [...(this.danmuList.value ?? []), danmuData]
    this.danmuList.setValue(newDanmus)
  }

  setDanmuColor(color: number) {
    this.danmuStyle.mutate({
      color: color
    })
  }

  setDanmuSize(size: PLVMPDanmuSize) {
    this.danmuStyle.mutate({
      size: size
    })
  }

  setDanmuMode(mode: PLVMediaPlayerDanmuMode) {
    this.danmuStyle.mutate({
      mode: mode
    })
  }

  setInputLayoutVisible(visible: boolean) {
    this.inputLayoutVisible.setValue(visible)
  }

  onDestroy(): void {
    MutableObserver.disposeAll(this.observers)
  }
}