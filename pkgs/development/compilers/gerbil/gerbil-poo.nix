{
  lib,
  fetchFromGitHub,
  gerbilPackages,
  ...
}:

{
  pname = "gerbil-poo";
  version = "unstable-2023-11-29";
  gerbil-package = "clan/poo";
  gerbilInputs = with gerbilPackages; [ gerbil-utils ];
  git-version = "0.2-5-gacf654e";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-poo";
    rev = "acf654eb040c548da260a7a5d52bafb057d23541";
    sha256 = "1pxv1j6hwcgjj67bb7vvlnyl3123r43ifldm6alm76v2mfp2vs81";
  };

  softwareName = "Gerbil-POO";
  version-path = "version";

  meta = {
    description = "Gerbil POO: Prototype Object Orientation for Gerbil Scheme";
    homepage = "https://github.com/fare/gerbil-poo";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
