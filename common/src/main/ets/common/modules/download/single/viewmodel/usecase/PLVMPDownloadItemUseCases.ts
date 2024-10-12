import {DownloadItemUpdateStateUseCase} from "./DownloadItemUpdateStateUseCase";

export class PLVMPDownloadItemUseCases {
  constructor(
    readonly downloadItemUpdateStateUseCase: DownloadItemUpdateStateUseCase
  ) {
  }
}