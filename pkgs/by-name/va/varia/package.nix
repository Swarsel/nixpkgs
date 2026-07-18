{
  lib,
  fetchFromGitHub,
  aria2,
  desktop-file-utils,
  ffmpeg,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "varia";
  version = "2025.10.14-1";

  src = fetchFromGitHub {
    owner = "giantpinkrobots";
    repo = "varia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Spx9boNNeOXGr82uVKSpHCbimflKKjbjur+aKsNZFhY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
  ];

  postInstall = ''
    rm $out/bin/varia
    mv $out/bin/varia-py.py $out/bin/varia
  '';

  # This replaces original varia wrapper
  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --add-flag "${lib.getExe aria2}"
      --add-flag "${lib.getExe ffmpeg}"
      --add-flag "NOSNAP"
    )
  '';

  dependencies = with python3Packages; [
    pygobject3
    aria2p
    yt-dlp
    emoji-country-flag
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Simple download manager based on aria2 and libadwaita";
    homepage = "https://giantpinkrobots.github.io/varia";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "varia";
  };
})
