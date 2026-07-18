{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  dbus,
  gdk-pixbuf,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  gtk4-layer-shell,
  hicolor-icon-theme,
  libevdev,
  libinput,
  libpulseaudio,
  librsvg,
  libxkbcommon,
  luajit,
  luajitPackages,
  pkg-config,
  rustPlatform,
  shared-mime-info,
  systemd,
  webp-pixbuf-loader,
  wrapGAppsHook4,
  features ? [ ],
}:

let
  hasFeature = f: features == [ ] || builtins.elem f features;
in
rustPlatform.buildRustPackage rec {
  pname = "ironbar";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "JakeStanger";
    repo = "ironbar";
    rev = "v${version}";
    hash = "sha256-9UPBSOgiyBOlUYZlx+xQN5PTPwDWCDdYKdCAhigzHwA=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    gdk-pixbuf
    glib
    gtk4-layer-shell
    glib-networking
    shared-mime-info
    adwaita-icon-theme
    hicolor-icon-theme
    gsettings-desktop-schemas
    libxkbcommon
    systemd
    dbus
  ]
  ++ lib.optionals (hasFeature "volume") [ libpulseaudio ]
  ++ lib.optionals (hasFeature "cairo") [ luajit ]
  ++ lib.optionals (hasFeature "keyboard") [
    libinput
    libevdev
  ];

  propagatedBuildInputs = [ gtk4 ];
  cargoHash = "sha256-ticVPKKfQnz21LpegKDwAtizi7bavIPEmpXsrZdRN48=";

  preFixup = ''
    gappsWrapperArgs+=(
      ${gappsWrapperArgs}
    )
  '';

  buildFeatures = features;
  buildNoDefaultFeatures = features != [ ];

  gappsWrapperArgs = ''
    # Thumbnailers
    --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share"
    --prefix XDG_DATA_DIRS : "${librsvg}/share"
    --prefix XDG_DATA_DIRS : "${webp-pixbuf-loader}/share"
    --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"

    # gtk-launch
    --suffix PATH : "${lib.makeBinPath [ gtk4 ]}"
  ''
  + lib.optionalString (hasFeature "cairo") ''
    --prefix LUA_PATH : "./?.lua;${luajitPackages.lgi}/share/lua/5.1/?.lua;${luajitPackages.lgi}/share/lua/5.1/?/init.lua;${luajit}/share/lua/5.1/\?.lua;${luajit}/share/lua/5.1/?/init.lua"
    --prefix LUA_CPATH : "./?.so;${luajitPackages.lgi}/lib/lua/5.1/?.so;${luajit}/lib/lua/5.1/?.so;${luajit}/lib/lua/5.1/loadall.so"
  '';

  runtimeDeps = [ luajitPackages.lgi ];

  meta = {
    description = "Customizable gtk-layer-shell wlroots/sway bar written in Rust";
    homepage = "https://github.com/JakeStanger/ironbar";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      yavko
      donovanglover
      jakestanger
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ironbar";
  };
}
