{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  gettext,
  granite,
  gtk3,
  json-glib,
  libgee,
  libhandy,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  switchboard-with-plugs,
  vala,
  wingpanel,
  zeitgeist,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-applications-menu";
  version = "8.0.4";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "applications-menu";
    tag = version;
    hash = "sha256-wHPdZnHDa9DirjGEfKyAa1jKjYD6aj8QwMZ9KxqLPkM=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      bc = "${bc}/bin/bc";
    })
  ];

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    granite
    gtk3
    json-glib
    libgee
    libhandy
    switchboard-with-plugs
    wingpanel
    zeitgeist
  ]
  ++
    # applications-menu has a plugin to search switchboard plugins
    # see https://github.com/NixOS/nixpkgs/issues/100209
    # wingpanel's wrapper will need to pick up the fact that
    # applications-menu needs a version of switchboard with all
    # its plugins for search.
    switchboard-with-plugs.buildInputs;

  mesonFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight and stylish app launcher for Pantheon";
    homepage = "https://github.com/elementary/applications-menu";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
