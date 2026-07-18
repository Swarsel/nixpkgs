{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  extlib,
  ocaml,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  pname = "cudf";
  version = "0.10";

  src = fetchFromGitLab {
    owner = "irill";
    repo = "cudf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-E4KXKnso/Q3ZwcYpKPgvswNR9qd/lafKljPMxfStedM=";
  };

  propagatedBuildInputs = [
    extlib
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    ounit2
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Library for CUDF format";
    homepage = "https://www.mancoosi.org/cudf/";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    downloadPage = "https://gforge.inria.fr/projects/cudf/";
  };
})
