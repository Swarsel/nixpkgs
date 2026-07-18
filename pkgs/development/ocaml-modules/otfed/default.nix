{
  lib,
  fetchFromGitHub,
  alcotest,
  base,
  buildDunePackage,
  ppx_deriving,
  ppx_inline_test,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "otfed";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "gfngfn";
    repo = "otfed";
    rev = finalAttrs.version;
    hash = "sha256-6QCom9nrz0B5vCmuBzqsM0zCs8tBLJC6peig+vCgMVA=";
  };

  buildInputs = [
    uutf
  ];

  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_inline_test
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "OpenType Font Format Encoder & Decoder";
    homepage = "https://github.com/gfngfn/otfed";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
