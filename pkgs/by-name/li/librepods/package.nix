{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libpulseaudio,
  openssl,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librepods";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "librepods-org";
    repo = "librepods";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6l1WjwjDbv5e3tDaWo9+XSEjr9ge/hKysIkeUqyiO4U=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libpulseaudio
    openssl
    qt6.qtbase
    qt6.qtconnectivity
    qt6.qtquick3d
    qt6.qttools
  ];

  __structuredAttrs = true;
  sourceRoot = "source/linux";

  meta = {
    description = "AirPods liberated from Apple's ecosystem";
    homepage = "https://github.com/librepods-org/librepods";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      thefossguy
      Cameo007
    ];

    mainProgram = "librepods";
  };
})
