{ fetchurl, alephone }:

alephone.makeWrapper rec {
  pname = "marathon";
  version = "20240510";
  desktopName = "Marathon";
  icon = alephone.icons + "/marathon.png";

  # nixpkgs-update: no auto update
  zip = fetchurl {
    hash = "sha256-shZ82e7veaaT/petxDQ8Fd7YtJPmTgxSCStf0kGfrFs=";
    url = "https://github.com/Aleph-One-Marathon/alephone/releases/download/release-${version}/Marathon-${version}-Data.zip";
  };

  meta = {
    description = "First chapter of the Marathon trilogy";

    longDescription = ''
      Alien forces have boarded the interstellar colony ship Marathon. The situation is dire. As a security officer onboard, it is your duty to defend the ship and its crew.

      Experience the start of Bungie’s iconic trilogy with Marathon. This release uses the original Marathon data files for the most authentic experience outside of a classic Mac or emulator.
    '';

    homepage = "https://alephone.lhowon.org/games/marathon.html";
  };

}
