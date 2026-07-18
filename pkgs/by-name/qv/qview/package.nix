{
  lib,
  stdenv,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  qt6,
  x11Support ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qview";
  version = "7.1";

  src = fetchFromGitHub {
    owner = "jurplel";
    repo = "qView";
    tag = finalAttrs.version;
    hash = "sha256-EcXhwJcgBLdXa/FQ5LuENlzwnLw4Gt2BGlBO1p5U8tI=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    qt6.qtimageformats
    qt6.qtsvg
    kdePackages.kimageformats
  ];

  qmakeFlags = [
    # See https://github.com/NixOS/nixpkgs/issues/214765
    "QT_TOOL.lrelease.binary=${lib.getDev qt6.qttools}/bin/lrelease"
  ]
  ++ lib.optionals (!x11Support) [ "CONFIG+=NO_X11" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Practical and minimal image viewer";
    homepage = "https://interversehq.com/qview/";
    changelog = "https://github.com/jurplel/qView/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ acowley ];
    platforms = lib.platforms.all;
    mainProgram = "qview";
  };
})
