{
  lib,
  fetchurl,
  fetchFromCodeberg,
}:
let
  src = lib.importJSON ./src.json;
in
{
  inherit (src) packageVersion;

  firefox = fetchurl (
    src.firefox
    // {
      url = "mirror://mozilla/firefox/releases/${src.firefox.version}/source/firefox-${src.firefox.version}.source.tar.xz";
    }
  );

  source = fetchFromCodeberg (
    src.source
    // {
      fetchSubmodules = true;
      owner = "librewolf";
      repo = "source";
    }
  );
}
