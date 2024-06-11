import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";

export class PLVMPMediaControllerRepo {

  readonly mediaMediator: PLVMPMediaMediator

  constructor(
    mediaMediator: PLVMPMediaMediator
  ) {
    this.mediaMediator = mediaMediator
  }

}