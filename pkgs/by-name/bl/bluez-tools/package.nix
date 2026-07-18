{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  pkg-config,
  readline,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bluez-tools";
  version = "0-unstable-2020-10-24";

  src = fetchFromGitHub {
    owner = "khvzak";
    repo = "bluez-tools";
    rev = "f65321736475429316f07ee94ec0deac8e46ec4a";
    hash = "sha256-GNtuMqMv/87bp3GX9Lh+CK/VKPluNVeWZRRVOD5NY3Y=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    readline
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Set of tools to manage bluetooth devices for linux";
    homepage = "https://github.com/khvzak/bluez-tools";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "bt-agent";
  };
})
