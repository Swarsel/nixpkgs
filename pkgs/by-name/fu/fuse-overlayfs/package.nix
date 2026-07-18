{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fuse3,
  nixosTests,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fuse-overlayfs";
  version = "1.17";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "fuse-overlayfs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oXSqyxe5+hsuFXKajuviqh2nKIz8Kw6rjLnb6XTF6GI=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ fuse3 ];
  enableParallelBuilding = true;
  passthru.tests = { inherit (nixosTests) podman; };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "FUSE implementation for overlayfs";
    longDescription = "An implementation of overlay+shiftfs in FUSE for rootless containers.";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ma9e ];
    platforms = lib.platforms.linux;
    mainProgram = "fuse-overlayfs";
    teams = [ lib.teams.podman ];
  };
})
