{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  flatpak,
  glib-networking,
  glycin-loaders,
  gtk4,
  gtksourceview5,
  json-glib,
  libadwaita,
  libdex,
  libglycin,
  libglycin-gtk4,
  libproxy,
  libsecret,
  libsoup_3,
  libxml2,
  libxmlb,
  libyaml,
  malcontent,
  md4c,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bazaar";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "bazaar-org";
    repo = "bazaar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9J+XI5JnV8Yfk3xRI/VM5RSG4eMafbw2rBRpPMIu5yA=";
  };

  outputs = [
    "out"
    # for libbge
    "lib"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    (python3.withPackages (p: [
      p.babel
      p.pygobject3
    ]))
  ];

  buildInputs = [
    appstream
    flatpak
    glib-networking
    gtk4
    gtksourceview5
    json-glib
    libadwaita
    libdex
    libglycin
    libglycin-gtk4
    glycin-loaders
    libproxy
    libsoup_3
    libxmlb
    libyaml
    malcontent
    md4c
    webkitgtk_6_0
    libsecret
  ];

  postInstall = ''
    moveToOutput bin/bge-demo $dev
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # bazaar needs bazaar-dl-worker in path
      --prefix PATH : $out/bin
      --prefix LD_LIBRARY_PATH : $lib/lib
      # gsettings schemas are moved to $lib
      --prefix XDG_DATA_DIRS : $lib/share
    )

    # isn't automatically picked out for some reason, while $dev/bin/bge-demo is...
    wrapGApp $out/bin/bazaar
  '';

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "FlatHub-first app store for GNOME";
    homepage = "https://github.com/kolunmi/bazaar";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      dtomvan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bazaar";
  };
})
