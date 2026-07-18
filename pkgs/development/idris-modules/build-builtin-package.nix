# Build one of the packages that comes with idris
# pname: The pname of the package
# deps: The dependencies of the package
{ build-idris-package, idris }:
pname: deps:
build-idris-package {

  inherit pname;
  inherit (idris) version;
  inherit (idris) src;
  idrisDeps = deps;
  noBase = true;
  noPrelude = true;

  postUnpack = ''
    sourceRoot=$sourceRoot/libs/${pname}
  '';

  meta = idris.meta // {
    description = "${pname} builtin Idris library";
  };
}
