{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "pure-splitmix";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "Lysxia";
    repo = "pure-splitmix";
    rev = finalAttrs.version;
    sha256 = "RUnsAB4hMV87ItCyGhc47bHGY1iOwVv9kco2HxnzqbU=";
  };

  doCheck = true;

  meta = {
    description = "Purely functional splittable PRNG";
    homepage = "https://github.com/Lysxia/pure-splitmix";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
