import { DependScope, extendNumber, minutes, MutableObserver, repeat } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaPlayViewState } from '../../../modules/media/viewmodel/viewstate/PLVMPMediaPlayViewState'
import { PLVMPMediaControllerViewModel } from '../../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import {
  PLVMPMediaControllerViewState
} from '../../../modules/mediacontroller/viewmodel/viewstate/PLVMPMediaControllerViewState'
import { getDisplayWindowWidth } from '../../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerGestureHandleLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  private mediaPlayViewState: PLVMPMediaPlayViewState | undefined = this.mediaViewModel.mediaPlayViewState.value
  private controllerViewState: PLVMPMediaControllerViewState | undefined = this.controllerViewModel.mediaControllerViewState.value
  private countClicksInDuration: number = 0
  private countClicksTimeoutId: number | null = null
  private readonly horizontalPanGestureState: PanGestureState = new PanGestureState()
  private readonly verticalPanGestureState: PanGestureState = new PanGestureState()
  private videoProgressOnStartDrag: number = 0
  private videoDuration: number = 0
  private observers: MutableObserver[] = []
  // 单击切换显示隐藏始终响应，其他事件的响应跟随状态
  private isHandleGesture: boolean = false

  aboutToAppear() {
    this.mediaViewModel.mediaPlayViewState.observe((viewState) => {
      this.mediaPlayViewState = viewState
      this.updateIsHandleGesture()
    }).pushTo(this.observers)

    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.controllerViewState = viewState
      this.updateIsHandleGesture()
    }).pushTo(this.observers)
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 1 })
          .onAction(() => {
            this.countClicksInDuration++
            if (this.countClicksTimeoutId !== null) {
              clearTimeout(this.countClicksTimeoutId)
            }
            this.countClicksTimeoutId = setTimeout((): void => this.handleClicks(), 200)
          }),
        LongPressGesture()
          .onAction((event: GestureEvent) => {
            this.controllerViewModel.handleLongPressSpeeding('start')
          })
          .onActionEnd((event: GestureEvent) => {
            this.controllerViewModel.handleLongPressSpeeding('end')
          })
          .onActionCancel(() => {
            this.controllerViewModel.handleLongPressSpeeding('end')
          }),
        PanGesture({
          direction: PanDirection.Horizontal
        })
          .onActionStart((event: GestureEvent) => {
            this.handleHorizontalPanGesture(event, 'start')
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handleHorizontalPanGesture(event, 'update')
          })
          .onActionEnd((event: GestureEvent) => {
            this.handleHorizontalPanGesture(event, 'end')
          })
          .onActionCancel(() => {
            this.handleHorizontalPanGesture(null, 'end')
          }),
        PanGesture({
          direction: PanDirection.Vertical
        })
          .onActionStart((event: GestureEvent) => {
            this.handleVerticalPanGesture(event, 'start')
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handleVerticalPanGesture(event, 'update')
          })
          .onActionEnd((event: GestureEvent) => {
            this.handleVerticalPanGesture(event, 'end')
          })
          .onActionCancel(() => {
            this.handleVerticalPanGesture(null, 'end')
          })
      )
    )
  }

  private handleClicks() {
    if (this.countClicksInDuration > 1) {
      this.onDoubleClick()
    } else {
      this.onSingleClick()
    }
    this.countClicksInDuration = 0
    if (this.countClicksTimeoutId !== null) {
      clearTimeout(this.countClicksTimeoutId)
    }
    this.countClicksTimeoutId = null
  }

  private onSingleClick() {
    this.controllerViewModel.onClickChangeControllerVisible()
  }

  private onDoubleClick() {
    if (!this.isHandleGesture) {
      return
    }
    if (this.mediaViewModel.mediaPlayViewState.value?.isPlaying) {
      this.mediaViewModel.pause()
    } else {
      this.mediaViewModel.start()
    }
  }

  private handleHorizontalPanGesture(event: GestureEvent | null, type: 'start' | 'update' | 'end') {
    if (!this.isHandleGesture) {
      return
    }
    const state = this.horizontalPanGestureState
    switch (type) {
      case 'start':
        if (event === null) {
          return;
        }
        state.startX = event.fingerList[0]?.globalX ?? null
        this.videoProgressOnStartDrag = this.mediaViewModel.mediaPlayViewState.value?.currentProgress ?? 0
        this.videoDuration = this.mediaViewModel.mediaPlayViewState.value?.duration ?? 0
        this.controllerViewModel.handleDragGestureSeek('update', this.videoProgressOnStartDrag)
        break;
      case 'update':
        if (event === null || state.startX === null) {
          return;
        }
        const dx = event.offsetX
        const percent = dx / getDisplayWindowWidth().vp
        const dprogress = percent * Math.min(this.videoDuration, minutes(3).toMillis())
        const targetProgress = extendNumber(this.videoProgressOnStartDrag + dprogress)
          .coerceIn_ext(0, this.videoDuration)
        this.controllerViewModel.handleDragGestureSeek('update', targetProgress)
        break;
      case 'end':
        state.startX = null
        state.startY = null
        state.lastConsumedX = 0
        state.lastConsumedY = 0
        state.lastX = 0
        state.lastY = 0
        this.controllerViewModel.handleDragGestureSeek('end', 0)
        break;
    }
  }

  private handleVerticalPanGesture(event: GestureEvent | null, type: 'start' | 'update' | 'end') {
    if (!this.isHandleGesture) {
      return
    }
    const state = this.verticalPanGestureState
    switch (type) {
      case 'start':
        if (event === null) {
          break;
        }
        state.startX = event.fingerList[0]?.globalX ?? null
        state.startY = event.fingerList[0]?.globalY ?? null
        state.lastY = state.startY ?? 0
        state.lastConsumedY = state.lastY
        break;
      case 'update':
        if (event === null || state.startX === null || state.startY === null) {
          return;
        }
        const sensitivity = 5
        state.lastY = state.startY + event.offsetY
        const dy = state.lastY - state.lastConsumedY
        if (Math.abs(dy) < sensitivity) {
          break;
        }
        const consumeCount = Math.floor(Math.abs(dy) / sensitivity)
        const direction = dy / Math.abs(dy)
        repeat(consumeCount, () => {
          if (state.isStartAtLeftSide()) {
            this.controllerViewModel.changeBrightness(direction > 0 ? 'down' : 'up')
          } else {
            this.controllerViewModel.changeVolume(direction > 0 ? 'down' : 'up')
          }
        })
        state.lastConsumedY = state.lastConsumedY + consumeCount * sensitivity * direction
        break;
      case 'end':
        state.startX = null
        state.startY = null
        state.lastConsumedX = 0
        state.lastConsumedY = 0
        state.lastX = 0
        state.lastY = 0
        break;
    }
  }

  private updateIsHandleGesture() {
    this.isHandleGesture = this.mediaPlayViewState !== undefined
      && this.controllerViewState !== undefined
      && !this.controllerViewState.controllerLocking
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}

class PanGestureState {
  startX: number | null = null
  startY: number | null = null
  lastConsumedX: number = 0
  lastConsumedY: number = 0
  lastX: number = 0
  lastY: number = 0

  isStartAtLeftSide(): boolean | undefined {
    if (this.startX === null) {
      return undefined
    }
    return this.startX < getDisplayWindowWidth().vp / 2
  }
}