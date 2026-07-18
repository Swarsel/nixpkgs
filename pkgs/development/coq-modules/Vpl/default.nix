{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "Vpl";
  defaultVersion = if lib.versions.range "8.8" "8.9" coq.coq-version then "0.5" else null;
  owner = "VERIMAG-Polyhedra";
  release."0.5".hash = "sha256-mSD/xSweeK9WMxWDdX/vzN96iXo74RkufjuNvtzsP9o=";
  setSourceRoot = "sourceRoot=$(echo */coq)";

  meta = {
    description = "Coq interface to VPL abstract domain of convex polyhedra";
    homepage = "https://amarechal.gitlab.io/home/projects/vpl/";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
