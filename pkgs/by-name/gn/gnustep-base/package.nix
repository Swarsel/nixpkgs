{
  lib,
  aspell,
  audiofile,
  binutils-unwrapped,
  clangStdenv,
  cups,
  fetchpatch,
  fetchzip,
  giflib,
  gmp,
  gnustep-libobjc,
  gnustep-make,
  gnutls,
  icu,
  libffi,
  libgcrypt,
  libiberty,
  libiconv,
  libjpeg,
  libpng,
  libtiff,
  libxml2,
  libxslt,
  pkg-config,
  portaudio,
  wrapGNUstepAppsHook,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "gnustep-base";
  version = "1.29.0";

  src = fetchzip {
    url = "ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-base-${finalAttrs.version}.tar.gz";
    hash = "sha256-4fjdsLBsYEDxLOFrq17dKii2sLKvOaFCu0cw3qQtM5U=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  patches = [
    ./fixup-paths.patch
    # https://github.com/gnustep/libs-base/issues/212 / https://www.sogo.nu/bugs/view.php?id=5416#c15585
    (fetchpatch {
      revert = true;
      sha256 = "02awigkbhqa60hfhqfh2wjsa960y3q6557qck1k2l231piz2xasa";
      url = "https://github.com/gnustep/libs-base/commit/bd5f2909e6edc8012a0a6e44ea1402dfbe1353a4.patch";
    })
    # https://github.com/gnustep/libs-base/issues/294
    (fetchpatch {
      sha256 = "PyOmzRIirSKG5SQY+UwD6moCidPb8PXCx3aFgfwxsXE=";
      url = "https://github.com/gnustep/libs-base/commit/37913d006d96a6bdcb963f4ca4889888dcce6094.patch";
    })
    # https://github.com/gnustep/libs-base/pull/334
    (fetchpatch {
      excludes = [ "ChangeLog" ];
      hash = "sha256-r0qpxjpEM6y+F/gju6JhpDNxnFJNHFG/mt3NmC1hWrs=";
      url = "https://github.com/gnustep/libs-base/commit/b4feee311f2beaf499a5742967213f523de30f16.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGNUstepAppsHook
  ];

  propagatedBuildInputs = [
    aspell
    audiofile
    binutils-unwrapped
    cups
    giflib
    gmp
    gnustep-libobjc
    gnutls
    icu
    libffi
    libgcrypt
    libiberty
    libiconv
    libjpeg
    libpng
    libtiff
    libxml2
    libxslt
    portaudio
  ];

  propagatedNativeBuildInputs = [
    gnustep-make
  ];

  meta = {
    description = "Implementation of AppKit and Foundation libraries of OPENSTEP and Cocoa";
    homepage = "https://gnustep.github.io/";

    changelog = "https://github.com/gnustep/libs-base/releases/tag/base-${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }";

    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      ashalkhakov
      dblsaiko
    ];

    platforms = lib.platforms.linux;
  };
})
