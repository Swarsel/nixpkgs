{
  lib,
  stdenv,
  fetchFromSourcehut,
  hareHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hare-xml";
  version = "0.25.2.0";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare-xml";
    tag = finalAttrs.version;
    hash = "sha256-YAXUt/gLtGgT/4XXwaVaFEkeWMTBxwjUeeHHm8o3QcA=";
  };

  nativeBuildInputs = [ hareHook ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  doCheck = true;

  meta = {
    inherit (hareHook.meta) platforms badPlatforms;
    description = "This package provides XML support for Hare";
    homepage = "https://git.sr.ht/~sircmpwn/hare-xml/";
    license = with lib.licenses; [ mpl20 ];
    maintainers = with lib.maintainers; [ sikmir ];
  };
})
