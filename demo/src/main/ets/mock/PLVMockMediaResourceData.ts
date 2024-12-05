import {
  error,
  PLVGeneralApiManager,
  PLVMediaPlayerAppContext,
  PLVMediaResource,
  PLVUrlMediaResource,
  PLVViewerParam,
  PLVVodMainAccountAuthentication,
  PLVVodMediaResource
} from '@polyvharmony/media-player-sdk';
import {PLVMediaDownloadSetting} from '@polyvharmony/media-player-sdk-addon-cache-down';

const mockAuthentication: PLVVodMainAccountAuthentication = {
  userId: "e97dbe3e64",
  secretKey: "zMV29c519P"
}

const mockViewerParam: PLVViewerParam = {
  viewerId: "123",
  viewerName: "123"
}

export class PLVMockMediaResourceData {

  // <editor-fold defaultstate="collapsed" desc="单例">

  private static readonly instance = new PLVMockMediaResourceData()

  private constructor() {
    this.setupMediaResources()
  }

  static getInstance() {
    return PLVMockMediaResourceData.instance
  }

  // </editor-fold>

  private mediaResources?: Promise<PLVMediaResource[]>

  private setupMediaResources() {
    this.setupMediaResourcesFromLocal()
    // this.setupMediaResourcesFromServer()
  }

  getMediaResources(): Promise<PLVMediaResource[]> {
    if (!this.mediaResources) {
      error("Must call setup before getMediaResources")
    }
    return this.mediaResources
  }

  private setupMediaResourcesFromLocal() {
    this.mediaResources = Promise.resolve([
      vod("e97dbe3e648aefc2eb6f68b96db9db6c_e"),
      vod("e97dbe3e6401ea8f76617bafe32f57e9_e"),
      vod("e97dbe3e64ed6e0aac558e43787df1b4_e"),
      vod("e97dbe3e646f8f565c015f361025c51c_e"),
      vod("e97dbe3e64755eda79bbda0c8c9a939e_e"),
      vod("e97dbe3e6492596e7e680c4c7b99ca1b_e"),
      vod("e97dbe3e641a81a1e87750a2522b22c9_e"),
      vod("e97dbe3e64f6f6d1f75aa6d16a2d128e_e"),
      vod("e97dbe3e64b6dd24f868c16335570343_e"),
      vod("e97dbe3e64b2ab3301c3289a5731cbb0_e"),
      vod("e97dbe3e649c4f6743ca640bda94230c_e"),
      vod("e97dbe3e64ae88c87769c9dba0aad552_e"),
      vod("e97dbe3e640cd100431e12a8f8313c7d_e"),
      vod("e97dbe3e6423671524f4601cb652bd0d_e"),
      vod("e97dbe3e645083078cb42da5aac89b7f_e"),
      vod("e97dbe3e64414e6dad17196f652c021f_e"),
      vod("e97dbe3e64fba07447f7c37b283fd76d_e"),
      vod("e97dbe3e643ea0a62166780aeab7c43c_e"),
      vod("e97dbe3e64436506a71c7cbeecf001de_e"),
      vod("e97dbe3e64b564d0daac43002effcb48_e"),
      vod("e97dbe3e64e4f1bd6c28c395703fc4d8_e"),
      vod("e97dbe3e6400b7c243ecacf0a45e3fbb_e"),
      vod("e97dbe3e648ca60cad8017983a07ecc9_e"),
      vod("e97dbe3e646a24f4c61a45dcbf9354ce_e"),
      vod("e97dbe3e641b079d268330cc274fe3b4_e"),
      vod("e97dbe3e642eb6b15f9983949ffbdea7_e")
    ])
  }

  private setupMediaResourcesFromServer() {
    this.mediaResources = PLVGeneralApiManager.getVodVideoList(mockAuthentication, 1, 20)
      .then(result => {
        return result.data!.map(video => vod(video!.vid!))
      })
  }

}

function vod(videoId: string): PLVVodMediaResource {
  // 默认下载路径
  const defaultDownloadRoot = PLVMediaDownloadSetting.defaultSetting(PLVMediaPlayerAppContext.getInstance().appContext!).downloadRootDirectory
  return {
    videoId: videoId,
    authentication: mockAuthentication,
    viewerParam: mockViewerParam,
    scene: "vod",
    localVideoSearchPaths: [defaultDownloadRoot]
  }
}

function url(url: string): PLVUrlMediaResource {
  return {
    url: url
  }
}