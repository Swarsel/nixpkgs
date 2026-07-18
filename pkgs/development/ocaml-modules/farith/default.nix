{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  ppx_deriving,
  ppx_hash,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "farith";
  version = "0.1";

  src = fetchFromGitLab {
    owner = "pub";
    repo = "farith";
    tag = finalAttrs.version;
    hash = "sha256-9TGKeL3DXKEf2RLpkjOTC8aDQeLKSM9QUIiSkFCQW+8=";
    domain = "git.frama-c.com";
  };

  propagatedBuildInputs = [
    ppx_deriving
    ppx_hash
    zarith
  ];

  doCheck = true;
  minimalOCamlVersion = "4.10";

  meta = {
    description = "Modelisation of base 2 floating points with arbitrary exponent and mantisse size.";
    homepage = "https://git.frama-c.com/pub/farith";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
})
