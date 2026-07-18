{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  ffmpeg,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
  yt-dlp,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "video-downloader";
  version = "0.12.31";

  src = fetchFromGitHub {
    owner = "Unrud";
    repo = "video-downloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b/CZRw2/hMTKoLXVuqpRuNRmMoouZwr9wXvAysj2xeQ=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    yt-dlp
  ];

  # would require network connectivity
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
    )
  '';

  dontWrapGApps = true;
  pyproject = false; # Built with meson

  meta = {
    description = "GUI application based on yt-dlp";
    homepage = "https://github.com/Unrud/video-downloader";
    changelog = "https://github.com/Unrud/video-downloader/releases";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fliegendewurst ];
    mainProgram = "video-downloader";
  };
})
