{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  kdsingleapplication,
  libre-graph-api-cpp-qt-client,
  nix-update-script,
  qt6,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opencloud-desktop";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "opencloud-eu";
    repo = "desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b6KaWrthL2z/Ep+O7wFIXxjd+H8+sBqZz8nmoQijTQU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qttools
    kdePackages.extra-cmake-modules
    kdePackages.qtkeychain
    libre-graph-api-cpp-qt-client
    kdsingleapplication
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/opencloudcmd";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Desktop Application for OpenCloud";
    homepage = "https://opencloud.eu/en";
    changelog = "https://github.com/opencloud-eu/desktop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.FKouhai ];
    downloadPage = "https://github.com/opencloud-eu/desktop";
  };
})
