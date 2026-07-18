{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  darwin,
  docutils,
  pkgsStatic,
  python3,
  zlib,
  enableForMonotone ? false, # Is it being imported for Monotone use?
  static ? stdenv.hostPlatform.isStatic, # generates static libraries *only*
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "botan";
  version = "2.19.5";

  src = fetchurl {
    url = "http://botan.randombit.net/releases/Botan-${finalAttrs.version}.tar.xz";
    hash = "sha256-3+6g4KbybWckxK8B2pp7iEh62y2Bunxy/K9S21IsmtQ=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "doc"
    "man"
  ];

  postPatch = ''
    sed -e '1i#include <cstdint>' -i src/cli/cli.h
  '';

  strictDeps = true;

  nativeBuildInputs = [
    python3
    docutils
  ];

  buildInputs = [
    bzip2
    zlib
  ];

  doCheck = true;

  preInstall = ''
    if [ -d src/scripts ]; then
      patchShebangs src/scripts
    fi
  '';

  postInstall = ''
    cd "$out"/lib/pkgconfig
    ln -s botan-*.pc botan.pc || true
  '';

  __structuredAttrs = true;

  botanConfigureFlags = [
    "--prefix=${placeholder "out"}"
    "--bindir=${placeholder "bin"}/bin"
    "--docdir=${placeholder "doc"}/share/doc"
    "--mandir=${placeholder "man"}/share/man"
    "--no-install-python-module"
    "--build-targets=${lib.concatStringsSep "," finalAttrs.buildTargets}"
    "--with-bzip2"
    "--with-zlib"
    "--with-rst2man"
    "--cpu=${stdenv.hostPlatform.parsed.cpu.name}"
  ]
  ++ lib.optionals stdenv.cc.isClang [
    "--cc=clang"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isMinGW) [
    "--os=mingw"
  ];

  buildTargets = [
    "cli"
  ]
  ++ lib.optionals finalAttrs.finalPackage.doCheck [ "tests" ]
  ++ lib.optionals static [ "static" ]
  ++ lib.optionals (!static) [ "shared" ];

  configurePhase = ''
    runHook preConfigure
    python configure.py ''${botanConfigureFlags[@]}
    runHook postConfigure
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Cryptographic algorithms library";
    homepage = "https://botan.randombit.net";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "botan";

    knownVulnerabilities = lib.optional (
      !enableForMonotone
    ) "Botan2 is EOL and its full interface surface contains unpatched vulnerabilities";
  };
})
