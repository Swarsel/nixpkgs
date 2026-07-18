{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "spdx_licenses";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/kit-ty-kate/spdx_licenses/releases/download/v${version}/spdx_licenses-${version}.tar.gz";
    hash = "sha256-slXewgDbf1US8kk/NaxOoicnkwdliUOq+SemkjvyUis=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Library providing a strict SPDX License Expression parser";
    homepage = "https://github.com/kit-ty-kate/spdx_licenses";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
