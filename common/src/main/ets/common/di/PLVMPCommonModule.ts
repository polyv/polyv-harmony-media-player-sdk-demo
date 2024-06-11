import {DependModule} from '@polyvharmony/media-player-sdk';
import {mediaModule} from '../modules/media/di/PLVMPMediaModule';
import {mediaControllerModule} from '../modules/mediacontroller/di/PLVMPMediaControlModule';
import {progressImageModule} from "../modules/progressImage/di/PLVMPProgressImageModule";

export const commonModule = new DependModule()

commonModule.include(mediaModule)
commonModule.include(mediaControllerModule)
commonModule.include(progressImageModule)
