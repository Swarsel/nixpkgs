{ callPackage, libjack2, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    pname = "patchmatrix";
    version = "0.26.0";
    additionalBuildInputs = [ libjack2 ];
    description = "JACK patchbay in flow matrix style";
    sha256 = "sha256-cqPHCnrAhHB6a0xmPUYOAsZfLsqnGpXEuGR1W6i6W7I=";
    url = "https://git.open-music-kontrollers.ch/lad/${pname}/snapshot/${pname}-${version}.tar.xz";
  }
)
