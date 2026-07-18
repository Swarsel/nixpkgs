{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  ppx_deriving,
  ppxlib,
  result,
  version ? if lib.versionAtLeast ppxlib.version "0.36" then "20251010" else "20250212",
}:

buildDunePackage {
  inherit version;
  pname = "visitors";

  src = fetchFromGitLab {
    owner = "fpottier";
    repo = "visitors";
    tag = version;

    hash =
      {
        "20250212" = "sha256-AFD4+vriwVGt6lzDyIDuIMadakcgB4j235yty5qqFgQ=";
        "20251010" = "sha256-3CHXECMHf/UWtLvy7fiOaxx6EizRRtm9HpqRxcRjH3I=";
      }
      ."${version}";

    domain = "gitlab.inria.fr";
  };

  propagatedBuildInputs = [
    ppxlib
    ppx_deriving
    result
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "OCaml syntax extension (technically, a ppx_deriving plugin) which generates object-oriented visitors for traversing and transforming data structures";
    homepage = "https://gitlab.inria.fr/fpottier/visitors";
    changelog = "https://gitlab.inria.fr/fpottier/visitors/-/raw/${version}/CHANGES.md";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
  };
}
