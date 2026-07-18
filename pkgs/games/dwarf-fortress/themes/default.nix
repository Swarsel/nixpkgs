{ lib, fetchFromGitHub, ... }:

let
  inherit (lib)
    importJSON
    licenses
    listToAttrs
    maintainers
    platforms
    ;
in

listToAttrs (
  map (v: {
    inherit (v) name;

    value = fetchFromGitHub {
      pname = v.name;
      version = v.version;
      owner = "DFgraphics";
      repo = v.name;
      rev = v.version;
      sha256 = v.sha256;

      meta = {
        license = licenses.unfree;

        maintainers = [
          maintainers.shazow
        ];

        platforms = platforms.all;
      };
    };
  }) (importJSON ./themes.json)
)
