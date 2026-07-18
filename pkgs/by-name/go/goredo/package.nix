{
  lib,
  fetchurl,
  buildGoModule,
  perl,
  python3,
  sharness,
  zstd,
}:

buildGoModule (finalAttrs: {
  pname = "goredo";
  version = "2.6.0";

  src = fetchurl {
    url = "http://www.goredo.cypherpunks.ru/download/goredo-${finalAttrs.version}.tar.zst";
    hash = "sha256-XTL/otfCKC55TsUBBVors2kgFpOFh+6oekOOafOhcUs=";
  };

  outputs = [
    "out"
    "info"
  ];

  patches = [
    # Adapt tests to Linux/nix-build requirements:
    ./fix-tests.diff
  ];

  nativeBuildInputs = [ zstd ];
  vendorHash = null;

  env = {
    inherit (sharness) SHARNESS_TEST_SRCDIR;
  };

  postBuild = ''
    ( cd $GOPATH/bin; ./goredo -symlinks )
    cd ..
  '';

  doCheck = true;

  nativeCheckInputs = lib.optionals finalAttrs.finalPackage.doCheck [
    python3
    perl
  ];

  checkPhase = ''
    runHook preCheck
    export PATH=$GOPATH/bin:$PATH
    (cd t; prove -f .)
    runHook postCheck
  '';

  postInstall = ''
    mkdir -p "$out/share/info"
    cp goredo.info "$out/share/info"
  '';

  modRoot = "./src";
  subPackages = [ "." ];

  meta = {
    description = "Makefile replacement that sucks less";
    homepage = "https://www.goredo.cypherpunks.ru";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.spacefrogg ];
    outputsToInstall = [ "out" ];
  };
})
