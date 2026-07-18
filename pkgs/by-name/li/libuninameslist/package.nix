{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libuninameslist";
  version = "20260107";

  src = fetchFromGitHub {
    owner = "fontforge";
    repo = "libuninameslist";
    rev = finalAttrs.version;
    hash = "sha256-o+moQBFXIhnqvAc9F08kLRiXVS5pJEuUJwWl4Y/8AS4=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = {
    description = "Library of Unicode names and annotation data";
    homepage = "https://github.com/fontforge/libuninameslist/";
    changelog = "https://github.com/fontforge/libuninameslist/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ erictapen ];
    platforms = lib.platforms.all;
  };
})
