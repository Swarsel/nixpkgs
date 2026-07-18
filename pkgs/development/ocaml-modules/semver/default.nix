{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ocaml,
}:

buildDunePackage (finalAttrs: {
  pname = "semver";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/rgrinberg/ocaml-semver/releases/download/${finalAttrs.version}/semver-${finalAttrs.version}.tbz";
    hash = "sha256-CjzDUtoe5Hvt6zImb+EqVIulRUUUQd9MmuJ4BH/2mLg=";
  };

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ alcotest ];

  meta = {
    description = "Semantic versioning module";
    homepage = "https://github.com/rgrinberg/ocaml-semver";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
