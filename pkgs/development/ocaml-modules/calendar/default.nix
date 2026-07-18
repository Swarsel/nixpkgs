{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  re,
}:

buildDunePackage (finalAttrs: {
  pname = "calendar";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "ocaml-community";
    repo = "calendar";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-+VQzi6pEMqzV1ZR84Yjdu4jsJEWtx+7bd6PQGX7TiEs=";
  };

  propagatedBuildInputs = [ re ];
  minimalOCamlVersion = "4.03";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Library for handling dates and times";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.gal_bolle ];
  };
})
