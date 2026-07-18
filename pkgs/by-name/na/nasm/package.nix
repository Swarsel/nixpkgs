{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gitUpdater,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nasm";
  version = "3.01";

  src = fetchurl {
    url = "https://www.nasm.us/pub/nasm/releasebuilds/${finalAttrs.version}/nasm-${finalAttrs.version}.tar.xz";
    hash = "sha256-tzJMvobnZ7ZfJvRn7YsSrYDhJOPMuJB2hVyY5Dqe3dQ=";
  };

  patches = [
    # Backport patches fixing nasm with gcc 15 and musl (and other?) platforms
    # https://github.com/netwide-assembler/nasm/issues/169
    (fetchpatch {
      hash = "sha256-zVeMFhoSY/HGYr4meIWBgt5Unq1fA8lM6h1Cl5fpbxo=";
      url = "https://github.com/netwide-assembler/nasm/commit/44e89ba9b650b5e1533bca43682e167f51a3511f.patch";
    })
    (fetchpatch {
      hash = "sha256-aXVS70O/wUkW8xtkwF7uwrQfTgGcNvxHrtGC0sjIPto=";
      url = "https://github.com/netwide-assembler/nasm/commit/746e7c9efa37cec9a44d84a1e96b8c38f385cc1f.patch";
    })
  ];

  nativeBuildInputs = [ perl ];
  doCheck = true;

  checkPhase = ''
    runHook preCheck

    make golden
    make test

    runHook postCheck
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    ignoredVersions = "rc.*";
    rev-prefix = "nasm-";
    url = "https://github.com/netwide-assembler/nasm.git";
  };

  meta = {
    description = "80x86 and x86-64 assembler designed for portability and modularity";
    homepage = "https://www.nasm.us/";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      pSub
    ];

    platforms = lib.platforms.unix;
    mainProgram = "nasm";
  };
})
