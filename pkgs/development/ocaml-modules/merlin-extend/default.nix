{
  lib,
  fetchurl,
  buildDunePackage,
  cppo,
}:

buildDunePackage (finalAttrs: {
  pname = "merlin-extend";
  version = "0.6.2";

  src = fetchurl {
    url = "https://github.com/let-def/merlin-extend/releases/download/v${finalAttrs.version}/merlin-extend-${finalAttrs.version}.tbz";
    hash = "sha256-R1WOfzC2RGLyucgvt/eHEzrPoNUTJFK2rXhI4LD013k=";
  };

  nativeBuildInputs = [ cppo ];

  meta = {
    description = "SDK to extend Merlin";
    homepage = "https://github.com/let-def/merlin-extend";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
