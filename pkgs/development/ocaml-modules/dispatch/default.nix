{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  ocaml,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "dispatch";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "inhabitedtype";
    repo = "ocaml-dispatch";
    rev = finalAttrs.version;
    sha256 = "12r39ylbxc297cbwjadhd1ghxnwwcdzfjk68r97wim8hcgzxyxv4";
  };

  propagatedBuildInputs = [ result ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ alcotest ];
  duneVersion = "3";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Path-based dispatching for client- and server-side applications";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
