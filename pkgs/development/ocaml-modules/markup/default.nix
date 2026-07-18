{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ocaml,
  ounit2,
  uchar,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "markup";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "markup.ml";
    tag = finalAttrs.version;
    hash = "sha256-tsXz39qFSyL6vPYKG7P73zSEiraaFuOySL1n0uFij6k=";
  };

  propagatedBuildInputs = [
    uchar
    uutf
  ];

  doCheck = true;
  checkInputs = [ ounit2 ];

  meta = {
    description = "Pair of best-effort parsers implementing the HTML5 and XML specifications";
    homepage = "https://github.com/aantron/markup.ml/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gal_bolle ];
  };

})
