export default class Socket {
  constructor(dispatch) {
    this.dispatch = dispatch
    this.ws = new WebSocket('ws://localhost:4000/socket', {})
    this.channels = {}
    this.ws.connect()
  }

  joinProject(id) {
    this.join(`project:${id}`, { projectId: id })
  }

  join(room, attrs = {}) {
    const channel = this.ws.channel(room, {})
    this.channels[room] = channel
    channel.join()
      .receive('ok', () => console.log(`[WS] Joined Channel: ${room}`))
      .receive('error', () => console.log(`[WS] Failed to join Channel: ${room}`))
      .receive('timeout', () => console.log(`[WS] Still waiting to join Channel: ${room}`))

    channel.on('event', payload => {
      const { eventName, data } = payload

      if (eventName === 'update:build') {
        this.dispatch(updateBuild(data))
      }

      // ...
    })
  }

  leaveProject(id) {
    this.leave(`project:${id}`)
  }

  leave(room) {
    this.channels[room].leave()
      .receive('ok', () => {
        console.log(`[WS] Leaving Channel: ${room}`)
        delete this.channels[room]
      })
  }
}
