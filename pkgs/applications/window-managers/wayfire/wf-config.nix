{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doctest,
  glm,
  libevdev,
  libxml2,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wf-config";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wf-config";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WcGt6yl2LpLnAOVtiCyMyWsoMAUMG1MYhvW/m2DDMX4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libevdev
    libxml2
  ];

  propagatedBuildInputs = [
    glm
  ];

  mesonFlags = [
    (lib.mesonEnable "tests" (stdenv.buildPlatform.canExecute stdenv.hostPlatform))
  ];

  doCheck = true;

  nativeCheckInputs = [
    cmake
  ];

  checkInputs = [
    doctest
  ];

  # CMake is just used for finding doctest.
  dontUseCmakeConfigure = true;

  meta = {
    description = "Library for managing configuration files, written for Wayfire";
    homepage = "https://github.com/WayfireWM/wf-config";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      teatwig
      wucke13
      wineee
    ];

    platforms = lib.platforms.unix;
  };
})
