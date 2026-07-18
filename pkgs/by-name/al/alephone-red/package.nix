{ fetchurl, alephone }:

alephone.makeWrapper {
  pname = "marathon-red";
  version = "0";
  desktopName = "Marathon-Red";

  zip = fetchurl {
    hash = "sha256-/GGjP0cFTwlndpovsVo4VnuY2TEU9+m2/WnYnanVI9w=";
    url = "http://files3.bungie.org/trilogy/MarathonRED.zip";
  };

  meta = {
    description = "Survival horror-esque Marathon conversion";
    homepage = "https://alephone.lhowon.org/scenarios.html";
  };

}
