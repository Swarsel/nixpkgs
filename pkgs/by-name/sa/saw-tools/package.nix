{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gmp,
  makeWrapper,
  ncurses,
  readline,
  testers,
  zlib,
}:

let
  sources = import ./sources.nix;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "saw-tools";
  version = "1.5";
  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ]
    ++ [
      makeWrapper
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gmp
    ncurses
    readline
    stdenv.cc.libc
    zlib
  ];

  installPhase = ''
    mkdir -p $out/lib $out/share

    mv bin $out/bin
    mv doc $out/share

    wrapProgram "$out/bin/saw" --prefix PATH : "$out/bin/"
  '';

  passthru.tests.version = testers.testVersion {
    command = "saw --version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Tools for software verification and analysis";
    homepage = "https://tools.galois.com/saw";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      thelissimus
    ];

    platforms = lib.attrNames sources;
    mainProgram = "saw";
  };
})
