# holesail sends UDP over a reliable stream

`holesail` tunnels UDP by writing each datagram into a udx stream with a 4 byte
length prefix. udx streams are reliable, ordered and congestion controlled, so
one dropped packet blocks everything queued behind it and the congestion window
backs off. For a 50-60 Hz game that reads as high, spiky ping.

udx also carries messages - unordered, no retransmission, no congestion control
- and `@hyperswarm/secret-stream` exposes them as `stream.trySend(buf)` and
`stream.on('message')`. That is what holesail used until upstream commit
`1989135` ("UDP Framing Concept", 2025-10-25).

`hyper-cmd-lib-net-udp-unordered-messages.patch` puts the message path back in
`@holesail/hyper-cmd-lib-net`, the module that owns both halves of the UDP
proxy. The release workflow applies it after `npm install` and before
`bare-make build`, so every binary built here carries it.

Two things to know:

* **Both ends of a tunnel must run a patched build.** One peer sending messages
  and the other reassembling length-prefixed bytes is just noise.
* **A udx message is capped.** It is spliced across a couple of MTU sized
  packets and reassembled on the far side, but it is dropped silently past two
  MTUs. Measured on udx-native 1.22.0 with its default 1200 byte MTU: 2000
  bytes arrives, 2050 disappears. The patch drops anything over 2000 bytes and
  logs one warning. DDNet caps packets at 1400, so normal play is unaffected.

The patch is written against `@holesail/hyper-cmd-lib-net` 1.1.2, which is what
`holesail` 2.4.4 resolves to with the `NPM_CONFIG_BEFORE` pin the release
workflow uses. The apply step asserts that, and fails the build if the module
moves.
