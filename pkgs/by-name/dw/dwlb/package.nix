{
  lib,
  stdenv,
  fetchFromGitHub,
  fcft,
  pixman,
  pkg-config,
  unstableGitUpdater,
  wayland,
  wayland-protocols,
  wayland-scanner,
  writeText,
  # Configurable options
  configH ? null,
  # Boolean flags
  withCustomConfigH ? (configH != null),
}:

stdenv.mkDerivation {
  pname = "dwlb";
  version = "0-unstable-2025-05-20";

  src = fetchFromGitHub {
    owner = "kolunmi";
    repo = "dwlb";
    rev = "48dbe00bdb98a1ae6a0e60558ce14503616aa759";
    hash = "sha256-S0jkoELkF+oEmXqiWZ8KJYtWAHEXR/Y93jl5yHgUuSM=";
  };

  outputs = [
    "out"
    "man"
  ];

  # Allow alternative config.def.h usage. Taken from dwl.nix.
  postPatch =
    let
      configFile =
        if lib.isDerivation configH || builtins.isPath configH then
          configH
        else
          writeText "config.h" configH;
    in
    lib.optionalString withCustomConfigH "cp ${configFile} config.h";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    wayland-scanner
    wayland-protocols
    pixman
    fcft
    wayland
  ];

  env = {
    PREFIX = placeholder "out";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Fast, feature-complete bar for dwl";
    homepage = "https://github.com/kolunmi/dwlb";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bot-wxt1221
      lonyelon
    ];

    platforms = wayland.meta.platforms;
    mainProgram = "dwlb";
  };
}
