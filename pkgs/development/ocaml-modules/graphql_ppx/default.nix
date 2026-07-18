{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  ocaml,
  ppxlib,
  reason,
  result,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "graphql_ppx";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "reasonml-community";
    repo = "graphql-ppx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u49JHC8K5iMCOQRPYaMl00npJsIE6ePaeJ2jP/vnuvw=";
  };

  nativeBuildInputs = [ reason ];

  buildInputs = [
    ppxlib
    reason
  ];

  propagatedBuildInputs = [
    reason
    result
    yojson
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "GraphQL PPX rewriter for Bucklescript/ReasonML";
    homepage = "https://github.com/reasonml-community/graphql_ppx";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Zimmi48
      jtcoolen
    ];

    broken = lib.versionAtLeast ocaml.version "5.4";
  };
})
