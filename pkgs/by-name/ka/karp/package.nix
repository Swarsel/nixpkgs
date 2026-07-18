{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ghostscript,
  kdePackages,
  ninja,
  qpdf,
  qt6,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "karp";
  version = "0-unstable-2025-03-05";

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "karp";
    rev = "de6d42447c3ed15a102ec81c56c55ec5a0111a59";
    hash = "sha256-5mXD4qOL+gJn0kCHpnp4kp0E2SCCYfeI7A3oScX1uf8=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    qt6.qtbase
    kdePackages.kirigami
    kdePackages.kirigami-addons
    kdePackages.kcoreaddons
    kdePackages.kconfig
    kdePackages.ki18n
    kdePackages.kcrash
    qt6.qtdeclarative
    qt6.qtwayland
    qt6.qtsvg
    qpdf
    qt6.qtwebengine
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        qpdf
        ghostscript
      ]
    }"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "KDE alternative to PDF arranger";
    homepage = "https://apps.kde.org/karp/";

    license = with lib.licenses; [
      bsd3
      cc-by-sa-40
      cc0
      # FSFAP
      gpl2Only
      gpl3Only
      lgpl2Plus
      # https://invent.kde.org/graphics/karp/-/blob/master/LICENSES/LicenseRef-KDE-Accepted-GPL.txt
    ];

    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "karp";
  };
}
