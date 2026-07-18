{
  lib,
  fetchFromGitLab,
  glib-networking,
  gobject-introspection,
  gst_all_1,
  libadwaita,
  nix-update-script,
  python3Packages,
  wrapGAppsHook4,
  yt-dlp,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "monophony";
  version = "4.4.6";

  src = fetchFromGitLab {
    owner = "zehkira";
    repo = "monophony";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aDtz1VKOx+HvZxzXVEkFe2JMwMfdXmSJKq6ilI24TnI=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    # needed for gstreamer https
    glib-networking
  ]
  ++ (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gstreamer
  ]);

  postInstall = ''
    make install prefix=$out
  '';

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ yt-dlp ]}"
      "''${gappsWrapperArgs[@]}"
    )
  '';

  build-system = with python3Packages; [
    setuptools
    pip
  ];

  dependencies = with python3Packages; [
    mprisify
    requests
    ytmusicapi
    logboth
  ];

  dontWrapGApps = true;
  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/source";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux app for streaming music from YouTube";
    longDescription = "Monophony allows you to stream and download music from YouTube Music without ads, as well as create and import playlists without signing in.";
    homepage = "https://gitlab.com/zehkira/monophony";
    license = lib.licenses.bsd0;

    maintainers = with lib.maintainers; [
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "monophony";
  };
})
