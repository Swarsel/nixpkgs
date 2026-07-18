{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  zarith_stubs_js ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "integers_stubs_js";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "o1-labs";
    repo = "integers_stubs_js";
    rev = finalAttrs.version;
    sha256 = "sha256-lg5cX9/LQlVmR42XcI17b6KaatnFO2L9A9ZXfID8mTY=";
  };

  propagatedBuildInputs = [ zarith_stubs_js ];
  doCheck = true;
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Javascript stubs for the integers library in js_of_ocaml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bezmuth ];
  };
})
