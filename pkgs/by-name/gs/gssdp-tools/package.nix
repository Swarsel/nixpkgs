{
  lib,
  stdenv,
  gssdp_1_6,
  gtk4,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  replaceVars,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (gssdp_1_6) version src;
  pname = "gssdp-tools";

  patches = [
    # Allow building tools separately from the library.
    # This is needed to break the dependency cycle.
    (replaceVars ./standalone-tools.patch {
      inherit (finalAttrs) version;
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gssdp_1_6
    gtk4
    libsoup_3
  ];

  preConfigure = ''
    cd tools
  '';

  meta = {
    description = "Device Sniffer tool based on GSSDP framework";
    homepage = "http://www.gupnp.org/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.all;
    mainProgram = "gssdp-device-sniffer";
    teams = gssdp_1_6.meta.teams;
  };
})
