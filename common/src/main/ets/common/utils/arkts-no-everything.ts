export function usePadding(padding: {
  top?: number;
  bottom?: number;
  left?: number;
  right?: number;
  vertical?: number;
  horizontal?: number;
}) {
  return {
    top: padding.top ?? padding.vertical,
    bottom: padding.bottom ?? padding.vertical,
    left: padding.left ?? padding.horizontal,
    right: padding.right ?? padding.horizontal
  }
}

export const parent: string = '__container__'

export function toTopOf(anchor: string) {
  return {
    anchor,
    align: VerticalAlign.Top
  }
}

export function toBottomOf(anchor: string) {
  return {
    anchor,
    align: VerticalAlign.Bottom
  }
}

export function toCenterOf(anchor: string) {
  return {
    anchor,
    align: VerticalAlign.Center
  }
}

export function toStartOf(anchor: string) {
  return {
    anchor,
    align: HorizontalAlign.Start
  }
}

export function toEndOf(anchor: string) {
  return {
    anchor,
    align: HorizontalAlign.End
  }
}

export function toMiddleOf(anchor: string) {
  return {
    anchor,
    align: HorizontalAlign.Center
  }
}

export const any: (any: any) => any = (any: any) => any

let createIdCounter = 1

export function createId(id?: string): string {
  return id ?? `plv_media_player_comp_id_${createIdCounter++}`
}

// <editor-fold defaultstate="collapsed" desc="ohos declare">

declare enum VerticalAlign {
  Top,
  Center,
  Bottom
}

declare enum HorizontalAlign {
  Start,
  Center,
  End
}

// </editor-fold>