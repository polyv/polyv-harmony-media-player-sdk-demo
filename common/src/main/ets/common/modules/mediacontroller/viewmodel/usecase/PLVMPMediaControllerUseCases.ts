import {UpdateMediaStopOverlayUseCase} from "./UpdateMediaStopOverlayUseCase";

export class PLVMPMediaControllerUseCases {

  readonly updateMediaStopOverlayUseCase: UpdateMediaStopOverlayUseCase

  constructor(
    updateMediaStopOverlayUseCase: UpdateMediaStopOverlayUseCase
  ) {
    this.updateMediaStopOverlayUseCase = updateMediaStopOverlayUseCase
  }

}