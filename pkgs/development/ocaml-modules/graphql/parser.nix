{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  fmt,
  menhir,
  re,
}:

buildDunePackage (finalAttrs: {
  pname = "graphql_parser";
  version = "0.14.0";

  src = fetchurl {
    url = "https://github.com/andreas/ocaml-graphql-server/releases/download/${finalAttrs.version}/graphql-${finalAttrs.version}.tbz";
    sha256 = "sha256-v4v1ueF+NV7LvYIVinaf4rE450Z1P9OiMAito6/NHAY=";
  };

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    fmt
    re
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Library for parsing GraphQL queries";
    homepage = "https://github.com/andreas/ocaml-graphql-server";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
