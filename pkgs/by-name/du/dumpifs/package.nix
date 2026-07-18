{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  lz4,
  lzo,
  ucl,
  unstableGitUpdater,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumpifs";
  version = "0-unstable-2020-05-07";

  src = fetchFromGitHub {
    owner = "askac";
    repo = "dumpifs";
    rev = "b7bac90e8312eca2796f2003a52791899eb8dcd9";
    hash = "sha256-vFiMKcPfowLQQZXlXbq5ZR1X6zr7u3iQwz3o4A6aQMY=";
  };

  patches = [ ./package.patch ];
  nativeBuildInputs = [ clang ];

  buildInputs = [
    lzo
    lz4
    ucl
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 dumpifs exMifsLz4 exMifsLzo fixdecifs fixencifs uuu zzz -t $out/bin

    runHook postInstall
  '';

  postUnpack = ''
    rm ${finalAttrs.src.name}/{dumpifs,exMifsLzo,uuu,zzz}
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Tool for those who are interested in hacking MIB2 firmware";
    homepage = "https://github.com/askac/dumpifs";
    platforms = lib.platforms.unix;
    mainProgram = "dumpifs";
  };
})
