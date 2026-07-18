{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  # buildInputs
  apr,
  aprutil,
  biber,
  # nativeBuildInputs
  bison,
  boost,
  bzip2,
  cairo,
  cmake,
  curl,
  expat,
  flex,
  fontconfig,
  fop,
  freetype,
  fribidi,
  gd,
  gmp,
  graphite2,
  hunspell,
  libjpeg,
  libmspack,
  libpng,
  libressl,
  libxslt,
  log4cxx,
  mpfi,
  mpfr,
  pixman,
  pkg-config,
  popt,
  qt6Packages,
  runCommand,
  uriparser,
  writableTmpDirAsHomeHook,
  xz,
  zziplib,
}:
let
  # This is needed for some bootstrap packages.
  webArchivePrefix = "https://web.archive.org/web/20250323131915if_";
  miktexRemoteRepository = "https://ctan.org/tex-archive/systems/win32/miktex/tm/packages";
  miktexLocalRepository =
    runCommand "miktex-local-repository"
      {
        src1 = fetchurl {
          hash = "sha256-XYhbKlxhVSOlCcm0IOs2ddFgAt/CWXJoY6IuLSw74y4=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-zzdb1-2.9.tar.lzma";
        };

        src2 = fetchurl {
          hash = "sha256-5vLuGwjddqtJ5F/DtVKuRVRqgGNbkGFxRF41cXwseIs=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-zzdb3-2.9.tar.lzma";
        };

        src3 = fetchurl {
          hash = "sha256-fkh5KL+BU+gl8Sih8xBLi1DOx2vMuSflXlSTchjlGWQ=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-config-2.9.tar.lzma";
        };

        src4 = fetchurl {
          hash = "sha256-eJQdLhYetNlXAyyiGD/JRDA3fv0BbALwXtNfRxkLM7o=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-dvips.tar.lzma";
        };

        src5 = fetchurl {
          hash = "sha256-dxH/0iIL3SnjCSXLGAcNTb5cGJb5AQmV/JbH5CcPHdk=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-fontconfig.tar.lzma";
        };

        src6 = fetchurl {
          hash = "sha256-ysNREvnKWseqqN59cwNzlV21UmccbjSGFyno8lv2H+M=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/miktex-misc.tar.lzma";
        };

        src7 = fetchurl {
          hash = "sha256-DE1o66r2SFxxxuYeCRuFn6L1uBn26IFnje9b/qeVl6Q=";
          url = "${webArchivePrefix}/${miktexRemoteRepository}/tetex.tar.lzma";
        };
      }
      ''
        mkdir $out
        cp $src1 $out/miktex-zzdb1-2.9.tar.lzma
        cp $src2 $out/miktex-zzdb3-2.9.tar.lzma
        cp $src3 $out/miktex-config-2.9.tar.lzma
        cp $src4 $out/miktex-dvips.tar.lzma
        cp $src5 $out/miktex-fontconfig.tar.lzma
        cp $src6 $out/miktex-misc.tar.lzma
        cp $src7 $out/tetex.tar.lzma
      '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "miktex";
  version = "25.12";

  src = fetchFromGitHub {
    owner = "miktex";
    repo = "miktex";
    tag = finalAttrs.version;
    hash = "sha256-gg6qTyY1LkHcUxTQN92yYark0uVoQjXDTbTMD6BucXA=";
  };

  patches = [
    ./startup-config-support-nix-store.patch
    # Miktex will search exectables in "GetMyPrefix(true)/bin".
    # The path evaluate to "/usr/bin" in FHS style linux distribution,
    # compared to "/nix/store/.../bin" in NixOS.
    # As a result, miktex will fail to find e.g. 'pkexec','ksudo','gksu'
    # under /run/wrappers/bin in NixOS.
    # We fix this by adding the PATH environment variable to exectables' search path.
    ./find-exectables-in-path.patch
  ];

  postPatch = ''
    # dont symlink fontconfig to /etc/fonts/conf.d
    substituteInPlace Programs/MiKTeX/miktex/topics/fontmaps/commands/FontMapManager.cpp \
      --replace-fail 'this->ctx->session->IsAdminMode()' 'false'

    substituteInPlace \
      Libraries/MiKTeX/App/app.cpp \
      Programs/Editors/TeXworks/miktex/miktex-texworks.cpp \
      Programs/MiKTeX/Console/Qt/main.cpp \
      Programs/MiKTeX/PackageManager/mpm/mpm.cpp \
      Programs/MiKTeX/Yap/MFC/StdAfx.h \
      Programs/MiKTeX/initexmf/initexmf.cpp \
      Programs/MiKTeX/miktex/miktex.cpp \
      --replace-fail "log4cxx/rollingfileappender.h" "log4cxx/rolling/rollingfileappender.h"

    substitute cmake/modules/FindPOPPLER_QT5.cmake \
      cmake/modules/FindPOPPLER_QT6.cmake \
      --replace-fail "QT5" "QT6" \
      --replace-fail "qt5" "qt6"

    substituteInPlace Programs/TeXAndFriends/omega/otps/source/outocp.c \
      --replace-fail 'fprintf(stderr, s);' 'fprintf(stderr, "%s", s);'

    # we use unsigned-char for all platform
    substituteInPlace Programs/TeXAndFriends/Knuth/web/CMakeLists.txt \
      --replace-fail '--using-namespace=MiKTeX::TeXAndFriends' '--using-namespace=MiKTeX::TeXAndFriends --chars-are-unsigned'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    cmake
    curl
    flex
    fop
    libxslt
    pkg-config
    writableTmpDirAsHomeHook
    qt6Packages.wrapQtAppsHook
    qt6Packages.qttools
    qt6Packages.qt5compat
  ];

  buildInputs = [
    apr
    aprutil
    boost
    bzip2
    cairo
    expat
    fontconfig
    freetype
    fribidi
    gd
    gmp
    graphite2
    hunspell
    libjpeg
    log4cxx
    xz
    mpfr
    mpfi
    libmspack
    libressl
    pixman
    libpng
    popt
    uriparser
    zziplib
    qt6Packages.poppler
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_BOOTSTRAPPING" true)
    (lib.cmakeBool "USE_SYSTEM_POPPLER" true)
    (lib.cmakeBool "USE_SYSTEM_POPPLER_QT" true)
    (lib.cmakeBool "USE_SYSTEM_HARFBUZZ" false)
    (lib.cmakeBool "USE_SYSTEM_HARFBUZZ_ICU" false)
    (lib.cmakeBool "MIKTEX_SELF_CONTAINED" false)
    # Miktex infers install prefix by stripping CMAKE_INSTALL_BINDIR from the called program.
    # It should not be set to absolute path in default cmakeFlags, otherwise an infinite loop will happen.
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBEXECDIR" "libexec")
    (lib.cmakeFeature "MIKTEX_SYSTEM_LINK_TARGET_DIR" "${placeholder "out"}/bin")
    (lib.cmakeFeature "MIKTEX_USER_LINK_TARGET_DIR" "${placeholder "out"}/bin")
  ];

  env = {
    LANG = "C.UTF-8";
    MIKTEX_REPOSITORY = "file://${miktexLocalRepository}/";
    # Force use of unsigned char for all platform
    # See https://github.com/MiKTeX/miktex/issues/1440
    NIX_CFLAGS_COMPILE = "-funsigned-char";
  };

  doCheck = true;

  postFixup = ''
    wrapQtApp $out/bin/miktex-console
    wrapQtApp $out/bin/miktex-texworks
    $out/bin/miktexsetup finish --verbose
  ''
  # Biber binary is missing on ctan.org for aarch64-linux platform.
  + lib.optionalString (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux) ''
    ln -sf ${biber}/bin/biber $out/bin/biber
  '';

  # Todo: figure out the exact binary to be Qt wrapped.
  dontWrapQtApps = true;
  enableParallelBuilding = false;
  enableParallelChecking = false;

  meta = {
    description = "Modern TeX distribution";
    homepage = "https://miktex.org";

    license = with lib.licenses; [
      lppl13c
      gpl2Plus
      gpl3Plus
      publicDomain
    ];

    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.linux;
  };
})
