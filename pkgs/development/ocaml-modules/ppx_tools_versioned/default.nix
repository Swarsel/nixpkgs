{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ocaml-migrate-parsetree,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_tools_versioned";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "ocaml-ppx";
    repo = "ppx_tools_versioned";
    rev = finalAttrs.version;
    sha256 = "07lnj4yzwvwyh5fhpp1dxrys4ddih15jhgqjn59pmgxinbnddi66";
  };

  propagatedBuildInputs = [ ocaml-migrate-parsetree ];
  duneVersion = "3";

  meta = {
    description = "Tools for authors of syntactic tools (such as ppx rewriters)";
    homepage = "https://github.com/let-def/ppx_tools_versioned";
    license = lib.licenses.gpl2;
    maintainers = [ ];
  };
})
