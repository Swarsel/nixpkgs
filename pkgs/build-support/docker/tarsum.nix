{
  stdenv,
  docker,
  go,
  nixosTests,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [ go ];

  env = {
    CGO_ENABLED = 0;
    GO111MODULE = "off";
    GOFLAGS = "-trimpath";
  };

  buildPhase = ''
    runHook preBuild
    mkdir tarsum
    cd tarsum
    cp ${./tarsum.go} tarsum.go
    export GOPATH=$(pwd)
    export GOCACHE="$TMPDIR/go-cache"
    mkdir -p src/github.com/docker/docker/daemon/builder/remotecontext
    # We need to drop the internal as otherwise go refuses to use it.
    ln -sT ${docker.moby-src}/daemon/builder/remotecontext/internal/tarsum src/github.com/docker/docker/daemon/builder/remotecontext/tarsum
    go build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tarsum $out/bin/
    runHook postInstall
  '';

  disallowedReferences = [ go ];
  dontUnpack = true;
  name = "tarsum";

  passthru = {
    tests = {
      dockerTools = nixosTests.docker-tools;
    };
  };

  meta.mainProgram = "tarsum";
  meta.platforms = go.meta.platforms;
}
