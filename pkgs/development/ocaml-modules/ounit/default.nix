{
  stdenv,
  findlib,
  ocaml,
  ounit2,
}:

stdenv.mkDerivation {
  inherit (ounit2) version src meta;
  pname = "ocaml${ocaml.version}-ounit";
  strictDeps = true;
  nativeBuildInputs = [ findlib ];
  propagatedBuildInputs = [ ounit2 ];
  createFindlibDestdir = true;
  dontBuild = true;
  installTargets = "install-ounit version='${ounit2.version}'";

}
