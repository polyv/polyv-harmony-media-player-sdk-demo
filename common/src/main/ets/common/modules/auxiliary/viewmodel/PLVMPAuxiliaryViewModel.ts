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

    this.auxiliaryInfoViewState = this.repo.mediator.auxiliaryInfoViewState
    this.auxiliaryPlayViewState = this.repo.mediator.auxiliaryPlayViewState
    this.auxiliaryVideoInfoViewState = this.repo.mediator.auxiliaryVideoInfoViewState

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