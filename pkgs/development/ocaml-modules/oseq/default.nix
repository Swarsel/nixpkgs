{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  containers,
  qcheck,
}:

buildDunePackage (finalAttrs: {
  pname = "oseq";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "oseq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fyr/OKlvvHBfovtdubSW4rd4OwQbMLKWXghyU3uBy/k=";
  };

  doCheck = true;

  checkInputs = [
    containers
    qcheck
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Purely functional iterators compatible with standard `seq`";
    homepage = "https://c-cube.github.io/oseq/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
