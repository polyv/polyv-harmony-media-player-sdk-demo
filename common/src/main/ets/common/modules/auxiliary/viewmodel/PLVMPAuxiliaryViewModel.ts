import {PLVMPAuxiliaryRepo} from "../model/PLVMPAuxiliaryRepo";
import {MutableState} from '@polyvharmony/media-player-sdk';
import {PLVMPAuxiliaryInfoViewState} from "./viewstate/PLVMPAuxiliaryInfoViewState";
import {PLVMPAuxiliaryUseCases} from "./usecases/PLVMPAuxiliaryUseCases";
import {PLVMPAuxiliaryVideoInfoViewState} from "./viewstate/PLVMPAuxiliaryVideoInfoViewState";
import {PLVMPAuxiliaryPlayViewState} from "./viewstate/PLVMPAuxiliaryPlayViewState";

export class PLVMPAuxiliaryViewModel {

  private readonly repo: PLVMPAuxiliaryRepo
  private readonly useCases: PLVMPAuxiliaryUseCases

  readonly auxiliaryInfoViewState: MutableState<PLVMPAuxiliaryInfoViewState | null>
  readonly auxiliaryPlayViewState: MutableState<PLVMPAuxiliaryPlayViewState>
  readonly auxiliaryVideoInfoViewState: MutableState<PLVMPAuxiliaryVideoInfoViewState>

  constructor(
    repo: PLVMPAuxiliaryRepo,
    useCases: PLVMPAuxiliaryUseCases
  ) {
    this.repo = repo
    this.useCases = useCases

    this.auxiliaryInfoViewState = this.useCases.updateMediaStateUseCase.auxiliaryInfoViewState
    this.auxiliaryPlayViewState = this.useCases.updateMediaStateUseCase.auxiliaryPlayViewState
    this.auxiliaryVideoInfoViewState = this.useCases.updateMediaStateUseCase.auxiliaryVideoInfoViewState

    this.repo.auxiliaryMediaPlayer.getAuxiliaryListenerRegistry().onBeforeAdvertListener = this.useCases.beforePlayListener
  }

  setXComponent(component: any) {
    this.repo.setXComponent(component)
  }

  bind() {
    this.repo.bind()
  }

  unbind() {
    this.repo.unbind()
  }

}