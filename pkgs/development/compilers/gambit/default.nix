{ fetchurl, callPackage }:

callPackage ./build.nix rec {
  version = "4.9.5";

  src = fetchurl {
    url = "https://gambitscheme.org/4.9.5/gambit-v4_9_5.tgz";
    sha256 = "sha256-4o74218OexFZcgwVAFPcq498TK4fDlyDiUR5cHP4wdw=";
  };

  git-version = "v${version}";
}
