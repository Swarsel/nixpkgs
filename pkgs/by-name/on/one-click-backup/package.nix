{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "one-click-backup";
  version = "1.2.2.1";

  src = fetchFromGitLab {
    owner = "dev-nis";
    repo = "nis-one-click-backup-qt";
    rev = finalAttrs.version;
    hash = "sha256-F+gA+Z4gZoNJYdy28uIjqiJcwcNsyUzl6BXsiIZO0gE=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtdeclarative
  ];

  meta = {
    description = "Simple Program to backup folders to an external location by copying them";
    homepage = "https://gitlab.com/dev-nis/nis-one-click-backup-qt";
    changelog = "https://gitlab.com/dev-nis/nis-one-click-backup-qt/-/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ NIS ];
    platforms = lib.platforms.all;
    mainProgram = "NIS_One-Click-Backup_Qt";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
