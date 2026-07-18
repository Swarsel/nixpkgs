{
  lib,
  stdenv,
  boost,
  doxygen,
  fetchpatch,
  fetchzip,
  icu,
  librevenge,
  pkg-config,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libmspub";
  version = "0.1.5";

  src = fetchzip {
    url = "https://dev-www.libreoffice.org/src/libmspub/libmspub-${finalAttrs.version}.tar.xz";
    hash = "sha256-1At2aFAdPeoDKcsrv1hpZ1Eig0//tc3jaRpg1qn14xI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-evxEoQ0a6YHoymR+SEJwqfr7rkWp3JnsWOD1tfYfZOw=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/libmspub/-/raw/8721a52e09e14f905311abd3d5f2ad9bb3fe78a2/buildfix.diff";
    })
    (fetchpatch {
      hash = "sha256-oHXEWSOSod9VnOrFtdMQcHYm7EdKkG+S7Q9rfM0DaTg=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/libmspub/-/raw/9d565015753364fa458da19e5dd4ce8224cf9246/includes.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    boost
    doxygen
    icu
    librevenge
    zlib
  ];

  configureFlags = [ "--with-docs" ];

  meta = {
    description = "Microsoft Publisher import library";
    homepage = "https://wiki.documentfoundation.org/DLP/Libraries/libmspub";
    changelog = "https://git.libreoffice.org/libmspub/+/refs/tags/libmspub-${finalAttrs.version}/NEWS";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
})
