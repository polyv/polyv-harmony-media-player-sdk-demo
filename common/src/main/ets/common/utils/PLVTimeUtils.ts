/**
 * format milliseconds to mm:ss or HH:mm:ss
 */
export function formatDuration(durationInMs: number) {
  const duration = Math.floor(durationInMs / 1000)
  if (duration < 60) {
    const secondText = duration.toString().padStart(2, '0')
    return `00:${secondText}`
  }
  if (duration < 3600) {
    const minutes = Math.floor(duration / 60)
    const seconds = Math.floor(duration % 60)
    const minuteText = minutes.toString().padStart(2, '0')
    const secondText = seconds.toString().padStart(2, '0')
    return `${minuteText}:${secondText}`
  }
  const hours = Math.floor(duration / 3600)
  const minutes = Math.floor((duration % 3600) / 60)
  const seconds = Math.floor(duration % 60)
  const hourText = hours.toString().padStart(2, '0')
  const minuteText = minutes.toString().padStart(2, '0')
  const secondText = seconds.toString().padStart(2, '0')
  return `${hourText}:${minuteText}:${secondText}`
}