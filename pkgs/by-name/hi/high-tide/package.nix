{
  lib,
  fetchFromGitHub,
  alsa-utils,
  blueprint-compiler,
  desktop-file-utils,
  glib-networking,
  gst_all_1,
  libadwaita,
  libportal,
  libsecret,
  meson,
  ninja,
  nix-update-script,
  pipewire,
  pkg-config,
  python313Packages,
  wrapGAppsHook4,
}:

python313Packages.buildPythonApplication (finalAttrs: {
  pname = "high-tide";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Nokse22";
    repo = "high-tide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uZkXpzRIDzn6wT3GmwNQbtf2/G9ddU13f7iMkj9Qopc=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    meson
    ninja
    pkg-config
    blueprint-compiler
    desktop-file-utils
  ];

  buildInputs = [
    glib-networking
    libadwaita
    libportal
    pipewire # provides a gstreamer plugin for pipewiresink
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    libsecret
  ]);

  dependencies = [
    alsa-utils
  ]
  ++ (with python313Packages; [
    pygobject3
    tidalapi
    requests
    python-mpd2
    pypresence
  ]);

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Libadwaita TIDAL client for Linux";
    homepage = "https://github.com/Nokse22/high-tide";
    license = with lib.licenses; [ gpl3Plus ];

    maintainers = with lib.maintainers; [
      drafolin
      nilathedragon
      nyabinary
      griffi-gh
    ];

    platforms = lib.platforms.linux;
    mainProgram = "high-tide";
  };
})
