import {PLVMPDownloadListMediator} from "../mediator/PLVMPDownloadListMediator";

export class PLVMPDownloadListRepo {
  constructor(
    readonly mediator: PLVMPDownloadListMediator
  ) {
  }
}