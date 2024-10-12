import {PLVMPDownloadItemMediator} from "../mediator/PLVMPDownloadItemMediator";
import {PLVMPMediaMediator} from "../../../media/mediator/PLVMPMediaMediator";

export class PLVMPDownloadItemRepo {
  constructor(
    readonly mediator: PLVMPDownloadItemMediator,
    readonly mediaMediator: PLVMPMediaMediator
  ) {
  }
}