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

let uniqueIdCounter = 0

export function defineIds<T extends string>(...ids: T[]): { [P in T]: `${P}_{uniqueId}` } {
  const res = {} as any;
  for (const id of ids) {
    res[id] = `${id}_${uniqueIdCounter++}`
  }
  return res;
}

export type whatever = unknown

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