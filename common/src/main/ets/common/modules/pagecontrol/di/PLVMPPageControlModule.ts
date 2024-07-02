import {DependModule} from '@polyvharmony/media-player-sdk';
import {PLVMPPageControlViewModel} from "../viewmodel/PLVMPPageControlViewModel";

export const pageControlModule = new DependModule()

pageControlModule.provide(PLVMPPageControlViewModel, () => new PLVMPPageControlViewModel())