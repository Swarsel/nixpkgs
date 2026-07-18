{
  lib,
  stdenv,
  bash,
  fetchFromSourcehut,
  hareHook,
  makeWrapper,
  nix-update-script,
  replaceVars,
  scdoc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "haredo";
  version = "1.0.6";

  src = fetchFromSourcehut {
    owner = "~autumnull";
    repo = "haredo";
    rev = finalAttrs.version;
    hash = "sha256-wjowPlSIotP8RSV0whiVWne+irtDdoPD+iSC2F9GVfs=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Use nix store's bash instead of sh. `@bash@/bin/sh` is used, since haredo expects a posix shell.
    (replaceVars ./001-use-nix-store-sh.patch {
      inherit bash;
    })
  ];

  nativeBuildInputs = [
    hareHook
    makeWrapper
    scdoc
  ];

  env.PREFIX = placeholder "out";

  buildPhase = ''
    runHook preBuild

    hare build -o bin/haredo ./src
    scdoc <doc/haredo.1.scd >doc/haredo.1

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    ./bin/haredo ''${enableParallelChecking:+-j$NIX_BUILD_CORES} test/all

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp ./bin/haredo $out/bin
    cp ./doc/haredo.1 $out/share/man/man1

    runHook postInstall
  '';

  dontConfigure = true;
  enableParallelChecking = true;
  setupHook = ./setup-hook.sh;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "Simple and unix-idiomatic build automator";
    homepage = "https://sr.ht/~autumnull/haredo/";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ onemoresuza ];
    mainProgram = "haredo";
  };
})
