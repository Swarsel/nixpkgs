{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  gst_all_1,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metronome";
  version = "1.3.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "metronome";
    rev = finalAttrs.version;
    hash = "sha256-Sn2Ua/XxPnJjcQvWeOPkphl+BE7/BdOrUIpf+tLt20U=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
  ];

  # Workaround for the gettext-sys issue
  # https://github.com/Koka/gettext-rs/issues/114
  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.cc.isClang && lib.versionAtLeast stdenv.cc.version "16"
  ) "-Wno-error=incompatible-function-pointer-types";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-T/x5LpODpKWGA40W1je6jw1DS9attVUK4ZjAnRAyf6k=";
    name = "metronome-${finalAttrs.version}";
  };

  meta = {
    description = "Keep the tempo";

    longDescription = ''
      Metronome beats the rhythm for you, you simply
      need to tell it the required time signature and
      beats per minutes. You can also tap to let the
      application guess the required beats per minute.
    '';

    homepage = "https://gitlab.gnome.org/World/metronome";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "metronome";
  };
})
