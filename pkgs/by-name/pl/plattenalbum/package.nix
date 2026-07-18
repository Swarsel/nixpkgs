{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "plattenalbum";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "SoongNoonien";
    repo = "plattenalbum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e4282zs9z+UpAtF4fuVWpUtiUqC/Id3/kpEQd3C6Z38=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [ libadwaita ];

  preFixup = ''
    makeWrapperArgs+=(''${gappsWrapperArgs[@]})
  '';

  dependencies = with python3Packages; [
    pygobject3
    python-mpd2
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Client for the Music Player Daemon (originally named mpdevil)";
    homepage = "https://github.com/SoongNoonien/plattenalbum";
    changelog = "https://github.com/SoongNoonien/plattenalbum/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Only
      cc0
    ];

    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "plattenalbum";
  };
})
