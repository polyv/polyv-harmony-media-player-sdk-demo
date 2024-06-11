export class PLVMPProgressImageData {

  readonly url: string
  readonly buffer: ArrayBuffer

  constructor(
    url: string,
    buffer: ArrayBuffer
  ) {
    this.url = url
    this.buffer = buffer
  }

}