{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  imagemagick,
  nix-update-script,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "converseen";
  version = "0.15.1.3";

  src = fetchFromGitHub {
    owner = "Faster3ck";
    repo = "Converseen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3cHj7wnNAvFsVyvt5lQAhtFn6AjgiR08MIGchmj8fac=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    imagemagick
    qt5.qtbase
    qt5.qttools
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Batch image converter and resizer";
    homepage = "https://converseen.fasterland.net/";
    changelog = "https://github.com/Faster3ck/Converseen/blob/${finalAttrs.src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "converseen";
  };
})
