import { mutableStateOf } from '@polyvharmony/media-player-sdk';
import { display } from '@kit.ArkUI';

export class PLVFoldableManager {
  private static readonly instance = new PLVFoldableManager();

  private constructor() {
    this.observeFold()
  }

  static getInstance(): PLVFoldableManager {
    return PLVFoldableManager.instance;
  }

  readonly foldStatus = mutableStateOf(display.getFoldStatus())
  readonly foldDisplayMode = mutableStateOf(display.getFoldDisplayMode())

  private observeFold() {
    display.on("foldStatusChange", foldStatus => this.foldStatus.setValue(foldStatus))
    display.on("foldDisplayModeChange", foldDisplayMode => this.foldDisplayMode.setValue(foldDisplayMode))
  }
}