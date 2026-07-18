{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  nix-update-script,
  sdl3,
  useSDL3 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fna3d";
  version = "26.06";

  src = fetchFromGitHub {
    owner = "FNA-XNA";
    repo = "FNA3D";
    tag = finalAttrs.version;
    hash = "sha256-p85nZzpegjXQTUv64Pxhn6BxBTUN5bOs73cgqLu79GI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = if useSDL3 then [ sdl3 ] else [ SDL2 ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SDL3" useSDL3)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Accuracy-focused XNA4 reimplementation for open platforms";
    homepage = "https://fna-xna.github.io/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ mrtnvgr ];
    platforms = lib.platforms.linux;
  };
})
