{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsForQt5,
  pkg-config,
  udevCheckHook,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "projecteur";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "jahnf";
    repo = "Projecteur";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F7o93rBjrDTmArTIz8RB/uGBOYE6ny/U7ppk+jEhM5A=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
    udevCheckHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtgraphicaleffects
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX:PATH=${placeholder "out"}"
    "-DPACKAGE_TARGETS=OFF"
    "-DCMAKE_INSTALL_UDEVRULESDIR=${placeholder "out"}/lib/udev/rules.d"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Linux/X11 application for the Logitech Spotlight device (and similar devices)";
    homepage = "https://github.com/jahnf/Projecteur";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      benneti
    ];

    platforms = lib.platforms.linux;
    mainProgram = "projecteur";
  };
})
