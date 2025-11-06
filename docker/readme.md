# Dockerfile

For building k1 bash, best **not** to use it for building anything else.

## Publishing docker file

```
docker build . -t pellcorp/k1-bash-build
docker login
docker push pellcorp/k1-bash-build
```
