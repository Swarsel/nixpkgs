{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coinutils";
  version = "2.11.10";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "CoinUtils";
    rev = "releases/${finalAttrs.version}";
    hash = "sha256-Rbm45HRbRKQ6Cdup+gvKJ1xkK1HKG3irR5AIjhLer7g=";
  };

  patches = [
    (fetchpatch {
      extraPrefix = "CoinUtils/";
      hash = "sha256-8S6XteZvoJlL+5MWiOrW7HXsdcnzpuEFTyzX9qg7OUY=";
      stripLen = 1;
      url = "https://github.com/coin-or/CoinUtils/commit/1700ed92c2bc1562aabe65dee3b4885bd5c87fb9.patch";
    })
  ];

  doCheck = true;

  meta = {
    description = "Collection of classes and helper functions that are generally useful to multiple COIN-OR projects";
    homepage = "https://github.com/coin-or/CoinUtils";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ tmarkus ];
  };
})
