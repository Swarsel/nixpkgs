{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fftw,
  kdePackages,
  krita-unwrapped,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-plugin-gmic";
  version = "3.7.4.1";

  src = fetchFromGitHub {
    owner = "vanyossi";
    repo = "gmic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xyln60z9r4spPtN3r2+3a1e5yzd8+B7d9UAR3VsRZ78=";
  };

  postPatch = ''
    patchShebangs \
      translations/filters/csv2ts.sh \
      translations/lrelease.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.qttools
  ];

  buildInputs = [
    curl
    fftw
    krita-unwrapped
    kdePackages.kcoreaddons
    qt6.qtbase
  ];

  cmakeFlags = [
    (lib.cmakeFeature "GMIC_QT_HOST" "krita-plugin")
    # build krita's gmic instead of using the one from nixpkgs
    (lib.cmakeBool "ENABLE_SYSTEM_GMIC" false)
  ];

  dontWrapQtApps = true;
  sourceRoot = "${finalAttrs.src.name}/gmic-qt";

  meta = {
    description = "GMic plugin for Krita";
    homepage = "https://krita.org";
    license = lib.licenses.cecill21;
    maintainers = with lib.maintainers; [ lelgenio ];
  };
})
