{
  lib,
  fetchFromGitHub,
  glib-networking,
  glibcLocales,
  gobject-introspection,
  gtk3,
  libnotify,
  nix-update-script,
  python3Packages,
  replaceVars,
  steam-run,
  unzip,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xdg-utils,
}:

python3Packages.buildPythonApplication rec {
  pname = "minigalaxy";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "sharkwouter";
    repo = "minigalaxy";
    tag = version;
    hash = "sha256-YZhgVeWdVaNiTj7hvYuHbaVtoKN6EFoOANWdkrlj4dU=";
  };

  patches = [
    (replaceVars ./inject-launcher-steam-run.diff {
      steamrun = lib.getExe steam-run;
    })
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    glib-networking
    gtk3
    libnotify
    webkitgtk_4_1
  ];

  nativeCheckInputs = with python3Packages; [
    glibcLocales
    pytestCheckHook
    simplejson
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --suffix PATH : "${
        lib.makeBinPath [
          unzip
          xdg-utils
        ]
      }"
    )
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pygobject3
    requests
  ];

  dontWrapGApps = true;
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple GOG client for Linux";
    homepage = "https://sharkwouter.github.io/minigalaxy/";
    changelog = "https://github.com/sharkwouter/minigalaxy/blob/${version}/CHANGELOG.md";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ RoGreat ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/sharkwouter/minigalaxy/releases";
  };
}
