import {DownloadRequestBackgroundTaskUseCase} from './DownloadRequestBackgroundTaskUseCase';
import {DownloadUpdateListUseCase} from "./DownloadUpdateListUseCase";

export class PLVMPDownloadListUseCases {
  constructor(
    readonly downloadUpdateListUseCase: DownloadUpdateListUseCase,
    readonly downloadRequestBackgroundTaskUseCase: DownloadRequestBackgroundTaskUseCase
  ) {
  }
}