import {AuxiliaryUpdateMediaStateUseCase} from "./AuxiliaryUpdateMediaStateUseCase";
import {AuxiliaryBeforePlayListener} from "./AuxiliaryBeforePlayListener";

export class PLVMPAuxiliaryUseCases {
  constructor(
    readonly beforePlayListener: AuxiliaryBeforePlayListener,
    readonly updateMediaStateUseCase: AuxiliaryUpdateMediaStateUseCase
  ) {
  }
}