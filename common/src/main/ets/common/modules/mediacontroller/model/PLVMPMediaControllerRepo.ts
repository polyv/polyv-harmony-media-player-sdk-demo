import {PLVMPMediaMediator} from "../../media/mediator/PLVMPMediaMediator";
import {PLVMPMediaControllerMediator} from "../mediator/PLVMPMediaControllerMediator";

export class PLVMPMediaControllerRepo {

  readonly mediator: PLVMPMediaControllerMediator
  readonly mediaMediator: PLVMPMediaMediator

  constructor(
    mediator: PLVMPMediaControllerMediator,
    mediaMediator: PLVMPMediaMediator
  ) {
    this.mediator = mediator
    this.mediaMediator = mediaMediator
  }

}