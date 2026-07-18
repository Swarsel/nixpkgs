{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  gitUpdater,
  kdePackages,
  qt6,
  shared-mime-info,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "calligraplan";
  version = "4.0.1";

  src = fetchFromGitLab {
    owner = "office";
    repo = "calligraplan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OD719omgw+RZrFz6qWiFDFB4t6Lvvh2M2QXYAIh0H2I=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    cmake
    kdePackages.extra-cmake-modules
    shared-mime-info
  ];

  buildInputs = [
    qt6.qtbase
    kdePackages.karchive
    kdePackages.kcalendarcore
    kdePackages.kconfig
    kdePackages.kconfigwidgets
    kdePackages.kcoreaddons
    kdePackages.kdbusaddons
    kdePackages.kdiagram
    kdePackages.kguiaddons
    kdePackages.kholidays
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kio
    kdePackages.kitemmodels
    kdePackages.kitemviews
    kdePackages.kjobwidgets
    kdePackages.knotifications
    kdePackages.kparts
    kdePackages.ktextwidgets
    kdePackages.kwidgetsaddons
    kdePackages.kwindowsystem
    kdePackages.kxmlgui
    kdePackages.plasma-activities
    kdePackages.sonnet
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Project Management Application";
    homepage = "https://www.calligra.org/plan/";
    changelog = "https://invent.kde.org/office/calligraplan/-/tags/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "calligraplan";
  };
})
