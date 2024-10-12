import {DependModule} from '@polyvharmony/media-player-sdk';
import {mediaModule} from '../modules/media/di/PLVMPMediaModule';
import {mediaControllerModule} from '../modules/mediacontroller/di/PLVMPMediaControlModule';
import {progressImageModule} from "../modules/progressImage/di/PLVMPProgressImageModule";
import {pageControlModule} from "../modules/pagecontrol/di/PLVMPPageControlModule";
import {auxiliaryModule} from "../modules/auxiliary/di/PLVMPAuxiliaryModule";
import {downloadItemModule} from "../modules/download/single/di/PLVMPDownloadItemModule";

export const commonItemModule = new DependModule()

commonItemModule.include(mediaModule)
commonItemModule.include(mediaControllerModule)
commonItemModule.include(progressImageModule)
commonItemModule.include(auxiliaryModule)
commonItemModule.include(downloadItemModule)

export const commonPageModule = new DependModule()

commonPageModule.include(pageControlModule)
