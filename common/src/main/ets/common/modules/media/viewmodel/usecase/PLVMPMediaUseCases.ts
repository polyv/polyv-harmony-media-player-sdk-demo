import {UpdateMediaStateUseCase} from './UpdateMediaStateUseCase';
import {ObserveNetworkPoorUseCase} from "./ObserveNetworkPoorUseCase";
import {UpdateBufferingSpeedUseCase} from "./UpdateBufferingSpeedUseCase";
import {HandleAudioFocusUseCase} from "./HandleAudioFocusUseCase";

export class PLVMPMediaUseCases {

  readonly handleAudioFocusUseCase: HandleAudioFocusUseCase
  readonly updateMediaStateUseCase: UpdateMediaStateUseCase
  readonly observeNetworkPoorUseCase: ObserveNetworkPoorUseCase
  readonly updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase

  constructor(
    handleAudioFocusUseCase: HandleAudioFocusUseCase,
    updateMediaStateUseCase: UpdateMediaStateUseCase,
    observeNetworkPoorUseCase: ObserveNetworkPoorUseCase,
    updateBufferingSpeedUseCase: UpdateBufferingSpeedUseCase
  ) {
    this.handleAudioFocusUseCase = handleAudioFocusUseCase
    this.updateMediaStateUseCase = updateMediaStateUseCase
    this.observeNetworkPoorUseCase = observeNetworkPoorUseCase
    this.updateBufferingSpeedUseCase = updateBufferingSpeedUseCase
  }

}