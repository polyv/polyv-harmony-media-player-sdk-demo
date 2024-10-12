import {MutableState} from "@polyvharmony/media-player-sdk";
import {PLVMPDownloadListViewState} from "../viewstate/PLVMPDownloadListViewState";

export class PLVMPDownloadListMediator {
  readonly downloadedList = new MutableState<PLVMPDownloadListViewState>()
  readonly downloadingList = new MutableState<PLVMPDownloadListViewState>()
}