import { DependScope, extendArray, MutableObserver, PLVMediaRoute } from '@polyvharmony/media-player-sdk'
import { PLVMPMediaViewModel } from '../../modules/media/viewmodel/PLVMPMediaViewModel'
import { PLVMPMediaControllerViewModel } from '../../modules/mediacontroller/viewmodel/PLVMPMediaControllerViewModel'
import { isPortrait } from '../../utils/PLVDisplayUtils'

@Component
export struct PLVMediaPlayerRouteSelectLayout {
  @Consume dependScope: DependScope
  private mediaViewModel: PLVMPMediaViewModel = this.dependScope.get(PLVMPMediaViewModel)
  private controllerViewModel: PLVMPMediaControllerViewModel = this.dependScope.get(PLVMPMediaControllerViewModel)
  @State isVisible: boolean = false
  @State currentRoute: PLVMediaRoute | null = null
  @State supportRoutes: PLVMediaRoute[] = []
  @State httpDnsEnabled: boolean = false
  private readonly portraitStyle: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    this.controllerViewModel.mediaControllerViewState.observe((viewState) => {
      this.isVisible = extendArray(viewState.floatActionLayouts).lastOrNull_ext() === 'route'
    }).pushTo(this.observers)

    this.mediaViewModel.mediaInfoViewState.observe((viewState) => {
      this.currentRoute = viewState.route
      this.supportRoutes = viewState.supportRoutes
      this.httpDnsEnabled = viewState.httpDnsEnabled
    }).pushTo(this.observers)
  }

  build() {
    Stack({ alignContent: this.portraitStyle ? Alignment.Bottom : Alignment.End }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#99000000')
        .onClick(() => this.close())

      Column() {
        Row() {
          Text($r('app.string.plv_media_player_ui_component_route_title'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.portraitStyle ? '#1F1F1F' : '#FFFFFF')
          Blank()
          Image($r('app.media.plv_media_player_float_menu_close_icon'))
            .width(40)
            .height(40)
            .padding(10)
            .fillColor(this.portraitStyle ? '#666666' : '#99FFFFFF')
            .onClick(() => this.close())
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 8 })

        if (this.supportRoutes.length > 1) {
          Text($r('app.string.plv_media_player_ui_component_route_section_title'))
            .fontSize(14)
            .fontColor(this.portraitStyle ? '#636364' : '#99FFFFFF')
            .width('100%')
            .margin({ top: 16, bottom: 8 })

          Grid() {
            ForEach(this.supportRoutes, (route: PLVMediaRoute) => {
              GridItem() {
                Column({ space: 6 }) {
                  Text($r('app.string.plv_media_player_ui_component_route_name', route.index + 1))
                    .fontSize(15)
                    .fontColor(this.currentRoute?.index === route.index ? '#3F76FC' :
                      (this.portraitStyle ? '#333333' : '#FFFFFF'))
                  Text(route.index === 0
                    ? $r('app.string.plv_media_player_ui_component_route_recommended_desc')
                    : $r('app.string.plv_media_player_ui_component_route_backup_desc'))
                    .fontSize(12)
                    .fontColor(this.portraitStyle ? '#999999' : '#99FFFFFF')
                }
                .width('100%')
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.currentRoute?.index === route.index ? '#143F76FC' :
                  (this.portraitStyle ? '#F5F6F8' : '#1FFFFFFF'))
                .borderRadius(8)
                .border({
                  width: this.currentRoute?.index === route.index ? 1 : 0,
                  color: '#3F76FC'
                })
                .onClick(() => {
                  if (this.currentRoute?.index !== route.index) {
                    this.mediaViewModel.changeRoute(route)
                  }
                  this.close()
                })
              }
            }, (route: PLVMediaRoute) => route.index.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
          .height(this.getRouteGridHeight())
        }

        Text($r('app.string.plv_media_player_ui_component_dns_title'))
          .fontSize(14)
          .fontColor(this.portraitStyle ? '#636364' : '#99FFFFFF')
          .width('100%')
          .margin({ top: 16, bottom: 8 })

        Grid() {
          ForEach([true, false], (httpDns: boolean) => {
            GridItem() {
              Column({ space: 6 }) {
                Text(httpDns ? 'httpdns' : 'localdns')
                  .fontSize(15)
                  .fontColor(this.httpDnsEnabled === httpDns ? '#3F76FC' :
                    (this.portraitStyle ? '#333333' : '#FFFFFF'))
                Text(httpDns
                  ? $r('app.string.plv_media_player_ui_component_http_dns_desc')
                  : $r('app.string.plv_media_player_ui_component_local_dns_desc'))
                  .fontSize(12)
                  .fontColor(this.portraitStyle ? '#999999' : '#99FFFFFF')
              }
              .width('100%')
              .height(64)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.httpDnsEnabled === httpDns ? '#143F76FC' :
                (this.portraitStyle ? '#F5F6F8' : '#1FFFFFFF'))
              .borderRadius(8)
              .border({
                width: this.httpDnsEnabled === httpDns ? 1 : 0,
                color: '#3F76FC'
              })
              .onClick(() => {
                if (this.httpDnsEnabled !== httpDns) {
                  this.mediaViewModel.changeHttpDns(httpDns)
                }
                this.close()
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .width('100%')
        .height(64)
      }
      .width(this.portraitStyle ? '100%' : 360)
      .height(this.portraitStyle ? 192 + this.getRouteSectionHeight() : '100%')
      .padding({ left: 20, right: 20, bottom: 24 })
      .backgroundColor(this.portraitStyle ? '#FFFFFF' : '#E61B202D')
      .borderRadius(this.portraitStyle ? { topLeft: 16, topRight: 16 } : 0)
    }
    .width('100%')
    .height('100%')
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  private close() {
    this.controllerViewModel.popFloatActionLayout()
  }

  private getRouteGridHeight(): number {
    const rowCount = Math.ceil(this.supportRoutes.length / 2)
    const rowsGapHeight = Math.max(rowCount - 1, 0) * 12
    return rowCount * 64 + rowsGapHeight
  }

  private getRouteSectionHeight(): number {
    return this.supportRoutes.length > 1 ? 40 + this.getRouteGridHeight() : 0
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
