{ fetchurl, alephone }:

alephone.makeWrapper {
  pname = "rubicon-x";
  version = "20150620";
  desktopName = "Marathon-Rubicon-X";
  sourceRoot = "Rubicon X ƒ";

  zip = fetchurl {
    hash = "sha256-9UZii2VLDlAi0qJKq8LiMEPZDscfpLnnvuZcxROKuiQ=";
    url = "http://files5.bungie.org/marathon/marathonRubiconX.zip";
  };

  meta = {
    description = "Unofficial forth chapter of the Marathon series";

    longDescription = ''
      Rubicon X is a free, cross platform, first person shooter that continues the story of Bungie’s Marathon trilogy. First released as Marathon:Rubicon in 2001, Rubicon X is a complete overhaul of the original. It features all new high-resolution artwork, new and updated maps, and enough surprises to feel like a whole new game.
    '';

    homepage = "http://www.marathonrubicon.com/";
  };

}
