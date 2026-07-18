{
  lib,
  stdenv,
  fetchFromGitHub,
  geocode-glib_2,
  gexiv2,
  granite,
  gst_all_1,
  gtk3,
  libexif,
  libgee,
  libgphoto2,
  libgudev,
  libhandy,
  libportal-gtk3,
  libraw,
  libwebp,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  sqlite,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "elementary-photos";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "photos";
    rev = version;
    sha256 = "sha256-+aqBeGRisngbH/EALROTr0IZvyrWIlQvFFEgJNfv95Y=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    geocode-glib_2
    gexiv2
    granite
    gtk3
    libexif
    libgee
    libgphoto2
    libgudev
    libhandy
    libportal-gtk3
    libraw
    libwebp
    sqlite
  ]
  ++ (with gst_all_1; [
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
  ]);

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Photo viewer and organizer designed for elementary OS";
    homepage = "https://github.com/elementary/photos";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.photos";
    teams = [ lib.teams.pantheon ];
  };
}
