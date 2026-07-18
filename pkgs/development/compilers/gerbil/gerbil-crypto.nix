{
  lib,
  fetchFromGitHub,
  gerbilPackages,
  pkgs,
  ...
}:

{
  pname = "gerbil-crypto";
  version = "unstable-2023-11-29";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.secp256k1 ];
  gerbil-package = "clan/crypto";

  gerbilInputs = with gerbilPackages; [
    gerbil-utils
    gerbil-poo
  ];

  git-version = "0.1-1-g4197bfa";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-crypto";
    rev = "4197bfa71dc55657f79efd5cc21fe59839e840f2";
    sha256 = "1jdfz5x24dfvpwyfxalkhv83gf9ylyaqii1kg8rjl8dzickawrix";
  };

  softwareName = "Gerbil-crypto";
  version-path = "version";

  meta = {
    description = "Gerbil Crypto: Extra Cryptographic Primitives for Gerbil";
    homepage = "https://github.com/fare/gerbil-crypto";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
