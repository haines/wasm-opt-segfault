# wasm-opt segfaults when writing output file on Linux

```console
$ docker run --rm -it $(docker build --target=release --quiet .) >release.log 2>&1
```

[Logs and stack trace from release build](./release.log)

```console
$ docker run --rm -it $(docker build --target=debug --quiet .) >debug.log 2>&1
```

[Logs and stack trace from debug build](./debug.log)
