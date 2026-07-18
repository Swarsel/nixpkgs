{
  lib,
  SDL2,
  breeze,
  glib,
  gsettings-desktop-schemas,
  ibus,
  libcanberra,
  libwacom,
  libxcursor,
  libxft,
  libxkbfile,
  makeWrapper,
  mkKdeDerivation,
  pkg-config,
  qtsvg,
  qtwayland,
  replaceVars,
  runCommandLocal,
  xf86-input-evdev,
  xf86-input-libinput,
  xkeyboard_config,
  xorg-server,
}:
let
  # run gsettings with desktop schemas for using in "kcm_access" kcm
  # and in kaccess
  gsettings-wrapper = runCommandLocal "gsettings-wrapper" { nativeBuildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${glib}/bin/gsettings $out/bin/gsettings --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas.out}/share/gsettings-schemas/${gsettings-desktop-schemas.name}
  '';
in
mkKdeDerivation {
  pname = "plasma-desktop";

  patches = [
    (replaceVars ./kcm-access.patch {
      gsettings = "${gsettings-wrapper}/bin/gsettings";
    })
    ./no-discover-shortcut.patch
    (replaceVars ./wallpaper-paths.patch {
      wallpapers = "${lib.getBin breeze}/share/wallpapers";
    })
  ];

  extraBuildInputs = [
    qtsvg
    qtwayland

    SDL2
    libcanberra
    libwacom
    libxkbfile
    xkeyboard_config

    libxcursor
    libxft
    xf86-input-libinput
    xf86-input-evdev
    xorg-server

    ibus
  ];

  extraNativeBuildInputs = [ pkg-config ];
  # wrap kaccess with wrapped gsettings so it can access accessibility schemas
  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ gsettings-wrapper ]}" ];
}
