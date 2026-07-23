# www.ezpz.host

Website for ezpz.host.

## Development

```sh
make help    # list targets
make serve   # serves on localhost:8000
make check   # starts a server, runs scripts/smoke_test.sh against every
             # page (asserts 200s + that unknown paths 404), tears down
```

## Deployment

Publishes to GitHub Pages on every push to `main`.
