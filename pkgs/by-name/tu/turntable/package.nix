{
  lib,
  stdenv,
  desktop-file-utils,
  fetchFromCodeberg,
  glib-networking,
  glycin-loaders,
  json-glib,
  libadwaita,
  libglycin,
  libglycin-gtk4,
  libportal,
  libportal-gtk4,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
  # Per the upstream request. Key owned by Aleksana
  lastfmKey ? "b5027c5178ca2abfcc31bd04397c3c0e",
  lastfmSecret ? "8d375bdee925a2a35f241c04272bc862",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "turntable";
  version = "0.5.1";

  src = fetchFromCodeberg {
    owner = "GeopJr";
    repo = "Turntable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OXZjCkVf1XOh1joDE5SBKaQmblfu+zNr+EXaqWP7HhM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    libsoup_3
    json-glib
    libsecret
    libglycin
    libglycin-gtk4
    glycin-loaders
    glib-networking
    libportal
    libportal-gtk4
  ];

  mesonFlags = [
    (lib.mesonOption "lastfm_key" lastfmKey)
    (lib.mesonOption "lastfm_secret" lastfmSecret)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scrobbles your music to multiple services with playback controls for MPRIS players";

    longDescription = ''
      Keep track of your listening habits by scrobbling them
      to last.fm, ListenBrainz, Libre.fm and Maloja at the
      same time using your favorite music app's, favorite
      music app! Turntable comes with a highly customizable
      and sleek design that displays information about the
      currently playing song and allows you to control your
      music player, allowlist it for scrobbling and manage
      your scrobbling accounts. All MPRIS-enabled apps are
      supported.
    '';

    homepage = "https://turntable.geopjr.dev";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "dev.geopjr.Turntable";
  };
})
