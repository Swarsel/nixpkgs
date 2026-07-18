{
  lib,
  fetchFromGitHub,
  alcotest,
  base64,
  buildDunePackage,
  digestif,
  fmt,
  ppx_deriving,
  ppxlib,
  re,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "jwto";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "sporto";
    repo = "jwto";
    rev = finalAttrs.version;
    hash = "sha256-TOWwNyrOqboCm8Y4mM6GgtmxGO3NmyDdAX7m8CifA7Y=";
  };

  buildInputs = [ ppxlib ];

  propagatedBuildInputs = [
    digestif
    fmt
    yojson
    base64
    re
    ppx_deriving
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "JSON Web Tokens (JWT) for OCaml";
    homepage = "https://github.com/sporto/jwto";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Zimmi48
      jtcoolen
    ];
  };
})
