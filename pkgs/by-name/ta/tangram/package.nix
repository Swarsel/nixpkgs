{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  hicolor-icon-theme,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tangram";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = "Tangram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aK/oavYQJJYQaQ+PjxSDjSSvEaYz3G8aGXLdumOEXgk=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/meson.build --replace "/app/bin/blueprint-compiler" "blueprint-compiler"
    substituteInPlace src/bin.js troll/gjspack/bin/gjspack \
      --replace "#!/usr/bin/env -S gjs -m" "#!${gjs}/bin/gjs -m"
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    gobject-introspection
    hicolor-icon-theme
    meson
    ninja
    pkg-config
    python3
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    gjs
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk4
    libadwaita
    webkitgtk_6_0
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    (gst-plugins-good.override { gtkSupport = true; })
    gst-plugins-bad
  ]);

  # https://github.com/NixOS/nixpkgs/issues/31168#issuecomment-341793501
  preFixup = ''
    sed -e '2iimports.package._findEffectiveEntryPointName = () => "re.sonny.Tangram"' \
      -i $out/bin/re.sonny.Tangram
  '';

  dontPatchShebangs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Run web apps on your desktop";
    homepage = "https://github.com/sonnyp/Tangram";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      austinbutler
      chuangzhu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "re.sonny.Tangram";
    teams = [ lib.teams.gnome-circle ];
  };
})
