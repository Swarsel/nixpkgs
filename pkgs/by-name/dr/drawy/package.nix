{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  nix-update-script,
  pkg-config,
  qt6,
  shared-mime-info,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drawy";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "drawy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Y6CAdHgcCK9lIae+CwqSGml+FAvVzLzyIAKdw85dKmQ=";
    domain = "invent.kde.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    shared-mime-info
  ];

  buildInputs =
    (with qt6; [
      qtbase
      qttools
    ])
    ++ (with kdePackages; [
      extra-cmake-modules
      kconfig
      kconfigwidgets
      kcoreaddons
      kcrash
      kdoctools
      ki18n
      kiconthemes
      kwidgetsaddons
      kxmlgui
      syntax-highlighting
    ]);

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Handy and infinite brainstorming tool";
    homepage = "https://apps.kde.org/drawy/";
    changelog = "https://invent.kde.org/graphics/drawy/-/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      bsd2
      bsd3
      cc-by-sa-40
      cc0
      gpl2Plus
      gpl3Plus
      lgpl2Plus
      mit
      ofl
    ];

    maintainers = with lib.maintainers; [
      quarterstar
      sigmasquadron
      yiyu
    ];

    platforms = lib.platforms.all;
    mainProgram = "drawy";
  };
})
