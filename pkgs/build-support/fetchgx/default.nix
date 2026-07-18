{
  lib,
  cacert,
  go,
  gx,
  gx-go,
  stdenvNoCC,
}:

lib.fetchers.withNormalizedHash { } (
  {
    name,
    outputHash,
    outputHashAlgo,
    src,
  }:

  stdenvNoCC.mkDerivation {
    inherit src;
    inherit outputHash outputHashAlgo;

    nativeBuildInputs = [
      cacert
      go
      gx
      gx-go
    ];

    buildPhase = ''
      export GOPATH=$(pwd)/vendor
      mkdir -p vendor
      gx install
    '';

    doCheck = false;

    installPhase = ''
      mv vendor $out
    '';

    doInstallCheck = false;
    dontConfigure = true;
    name = "${name}-gxdeps";
    outputHashMode = "recursive";
    preferLocalBuild = true;
  }
)
