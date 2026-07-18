{
  lib,
  stdenv,
  fetchpatch,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "galleta";
  version = "20040505_1";

  src = fetchzip {
    url = "mirror://sourceforge/project/odessa/Galleta/${finalAttrs.version}/galleta_${finalAttrs.version}.zip";
    hash = "sha256-tc5XLToyQZutb51ZoBlGWXDpsSqdJ89bjzJwY8kRncA=";
  };

  patches = [
    # fix some GCC warnings.
    (fetchpatch {
      hash = "sha256-b8VJGSAoSnWteyUbC2Ue3tqkpho7gyn+E/yrN2O3G9c=";
      url = "https://salsa.debian.org/pkg-security-team/galleta/-/raw/998470d8151b2f3a4bec71ae340c30f252d03a9b/debian/patches/10_fix-gcc-warnings.patch";
    })
    # make Makefile compliant with Debian and add GCC hardening.
    (fetchpatch {
      hash = "sha256-+rnoTrlXtWl9zmZlkvqbJ+YlIXFCpKOqvxIkN8xxtsg=";
      url = "https://salsa.debian.org/pkg-security-team/galleta/-/raw/553c237a34995d9f7fc0383ee547d4f5cd004d5b/debian/patches/20_fix-makefile.patch";
    })
    # Fix cross compilation.
    # Galleta fails to cross build from source, because the upstream
    # Makefile hard codes the build architecture compiler. The patch
    # makes the compiler substitutable and galleta cross buildable.
    (fetchpatch {
      hash = "sha256-ZwymEVJy7KvLFvNOcVZqDtJPxEcpQBVg+u+G+kSDZBo=";
      url = "https://salsa.debian.org/pkg-security-team/galleta/-/raw/f0f51a5a9e5adc0279f78872461fa57ee90d6842/debian/patches/30-fix-FTBS-cross-compilation.patch";
    })
  ];

  makeFlags = [
    "-C src"
    "CC=cc"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp src/galleta $out/bin
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Examine the contents of the IE's cookie files for forensic purposes";
    homepage = "https://sourceforge.net/projects/odessa/files/Galleta";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "galleta";
  };
})
