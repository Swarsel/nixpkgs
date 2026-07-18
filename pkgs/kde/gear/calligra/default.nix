{
  lib,
  boost,
  eigen,
  fetchpatch,
  gsl,
  imath,
  libetonyek,
  libgit2,
  libodfgen,
  librevenge,
  libvisio,
  libwpd,
  libwpg,
  libwps,
  mkKdeDerivation,
  okular,
  perl,
  pkg-config,
  poppler,
  qtkeychain,
  qtsvg,
  qtwebengine,
  shared-mime-info,
}:

mkKdeDerivation {
  pname = "calligra";

  patches = [
    # Fix build with Poppler 26.04
    (fetchpatch {
      hash = "sha256-V21Bw0xV/E4a9v8Yrt0vZ3AU1LJFHul1k92u+nsp85I=";
      url = "https://invent.kde.org/office/calligra/-/commit/e9aae90db47ca87d639b8f2b17ec75c1b6093e27.patch";
    })
  ];

  extraBuildInputs = [
    boost
    eigen
    gsl
    imath
    libetonyek
    libgit2
    libodfgen
    librevenge
    libvisio
    libwpd
    libwpg
    libwps
    okular
    poppler
    qtkeychain
    qtsvg
    qtwebengine
  ];

  # Recommended by the upstream packaging instructions. RELEASE_BUILD disables
  # unmaintained components, like Braindump, from being built, and KDE_NO_DEBUG_OUTPUT
  # is supposed to improve performance in the finished package.
  extraCmakeFlags = [
    (lib.cmakeBool "RELEASE_BUILD" true)
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DKDE_NO_DEBUG_OUTPUT")
  ];

  extraNativeBuildInputs = [
    perl
    pkg-config
    shared-mime-info
  ];

  meta = {
    maintainers = with lib.maintainers; [
      zraexy
      sigmasquadron
    ];

    mainProgram = "calligralauncher";
  };
}
