![Logo of Caddy Server](./caddy.jpg)

# Caddy Server Docker &middot; [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)

A tiny 6.57MB Caddy image compressed with [UPX](https://github.com/upx/upx).

# Usage

Serve files in `$PWD`:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv productionwentdown/caddy
```

Overwrite `Caddyfile`:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv -v $PWD/Caddyfile:/etc/Caddyfile productionwentdown/caddy
```

Persist `.caddy` to avoid hitting Let's Encrypt's rate limit:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv -v $PWD/Caddyfile:/etc/Caddyfile -v $HOME/.caddy:/etc/.caddy productionwentdown/caddy
```

# Build with plugins

Using `docker build` arguments:
```
docker build -t caddy --build-arg plugins=github.com/abiosoft/caddy-git,github.com/zikes/gopkg .
```

You can also fork and edit plugger.go for more advanced plugin configuration

# Build without telemetry

```
docker build . -t caddy --build-arg telemetry=false
```

## Acknowledgments

Forked and modified from https://github.com/productionwentdown/caddy
