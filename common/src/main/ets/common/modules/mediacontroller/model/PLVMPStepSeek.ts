export function normalizeSeekStep(seconds: number): number {
  return Number.isInteger(seconds) && seconds >= 5 && seconds <= 60 ? seconds : 15
}

/** 尚未完成的跳转以上一次目标累加，实际定位限制在视频范围内。 */
export function stepSeekTarget(current: number, pending: number | undefined, duration: number,
  seconds: number, forward: boolean): number {
  const end = Number.isFinite(duration) ? Math.max(0, duration) : 0
  const position = pending ?? current
  const base = Number.isFinite(position) ? Math.max(0, Math.min(end, position)) : 0
  return Math.max(0, Math.min(end, base + normalizeSeekStep(seconds) * 1000 * (forward ? 1 : -1)))
}
