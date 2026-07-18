{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  gettext,
  git,
  imagemagick,
  nix-update-script,
  python3Packages,
  qt6,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "git-cola";
  version = "4.18.2";

  src = fetchFromGitHub {
    owner = "git-cola";
    repo = "git-cola";
    tag = "v${version}";
    hash = "sha256-oUh9XVj2FGRow3l5wBUGW+BN01ykLvsQH0uC/No22Do=";
  };

  nativeBuildInputs = [
    gettext
    qt6.wrapQtAppsHook
    imagemagick
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  buildInputs = [
    git
    qt6.qtbase
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ qt6.qtwayland ];

  nativeCheckInputs = [
    git
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  postInstall = ''
    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
      magick cola/icons/git-cola.svg -background none -resize ''${i}x''${i} $out/share/icons/hicolor/''${i}x''${i}/apps/${pname}.png
    done
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    polib
    pyqt6
    qtpy
    send2trash
  ];

  desktopItems = [
    "share/applications/git-cola-folder-handler.desktop"
    "share/applications/git-cola.desktop"
    "share/applications/git-dag.desktop"
  ];

  disabledTestPaths = [
    "qtpy/"
    "contrib/win32"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "cola/inotify.py" ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sleek and powerful Git GUI";
    homepage = "https://git-cola.github.io/";
    changelog = "https://github.com/git-cola/git-cola/blob/v${version}/CHANGES.rst";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bobvanderlinden ];
    mainProgram = "git-cola";
  };
}
