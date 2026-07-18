{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  ff-sig,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "polynomial";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "nomadic-labs";
    repo = "cryptography/ocaml-polynomial";
    rev = finalAttrs.version;
    hash = "sha256-is/PrYLCwStHiQsNq5OVRCwHdXjO2K2Z7FrXgytRfAU=";
  };

  propagatedBuildInputs = [
    zarith
    ff-sig
  ];

  doCheck = false; # circular dependencies
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Polynomials over finite field";
    homepage = "https://gitlab.com/nomadic-labs/ocaml-polynomial";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
