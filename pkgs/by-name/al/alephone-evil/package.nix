{ fetchurl, alephone }:

alephone.makeWrapper {
  pname = "marathon-evil";
  version = "0";
  desktopName = "Marathon-Evil";

  zip = fetchurl {
    hash = "sha256-Ja3kvg6fCkRWURgw4av1X0iglTkLrozvAqFnceX60SI=";
    url = "http://files3.bungie.org/trilogy/MarathonEvil.zip";
  };

  meta = {
    description = "First conversion for Marathon Infinity";
    homepage = "https://alephone.lhowon.org/scenarios.html";
  };

}
