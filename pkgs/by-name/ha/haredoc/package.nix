{
  lib,
  stdenv,
  hare,
  hareHook,
  scdoc,
}:
stdenv.mkDerivation {
  inherit (hare) version src;
  pname = "haredoc";

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    scdoc
    hareHook
  ];

  buildPhase = ''
    runHook preBuild

    hare build -o haredoc ./cmd/haredoc
    scdoc <docs/haredoc.1.scd >haredoc.1
    scdoc <docs/haredoc.5.scd >haredoc.5

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm0755 ./haredoc $out/bin/haredoc
    install -Dm0644 ./haredoc.1 $out/share/man/man1/haredoc.1
    install -Dm0644 ./haredoc.5 $out/share/man/man5/haredoc.5

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "Hare's documentation tool";
    homepage = "https://harelang.org/";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "haredoc";
  };
}
