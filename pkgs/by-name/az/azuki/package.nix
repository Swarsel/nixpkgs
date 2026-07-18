{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  fonts = [
    {
      downloadVersion = "121";
      hash = "sha256-AMpEJDD8lN0qWJ5C0y4V+/2JE/pKQrUHGfKHcnV+dhA=";
      name = "azuki";
    }
    {
      downloadVersion = "B120";
      hash = "sha256-GoXnDX9H6D1X0QEgrD2jmQp7ek081PpO+xR3OdIY8Ck=";
      name = "azuki-b";
    }
    {
      downloadVersion = "L120";
      hash = "sha256-rvWvSuvLnK3m2+iyKPQyIB1UGjg8dAW5oygjsLCQZ48=";
      name = "azuki-l";
    }
    {
      downloadVersion = "LB100";
      hash = "sha256-zpGomVshCe2W2Z2C5UGtVrJ2k7F//MftndSHPHmG290=";
      name = "azuki-lb";
    }
    {
      downloadVersion = "LP100";
      hash = "sha256-Q/ND3dv8q7WTQx4oYVY5pTiGl4Ht89oA+tuCyfPOLUk=";
      name = "azuki-lp";
    }
    {
      downloadVersion = "P100";
      hash = "sha256-s4uodxyXP5R7jwkzjmg6qJZCllJ/MtgkkVOeELI8hLI=";
      name = "azuki-p";
    }
  ];

in
stdenvNoCC.mkDerivation {
  pname = "azuki";
  version = "0-unstable-2021-07-02";

  installPhase = ''
    runHook preInstall

    for font in $srcs; do
      install -Dm644 $font/azukifont*/*.ttf -t $out/share/fonts/truetype
    done

    runHook postInstall
  '';

  sourceRoot = "azuki";

  srcs = map (
    {
      downloadVersion,
      hash,
      name,
    }:
    fetchzip {
      inherit name hash;
      stripRoot = false;
      url = "https://azukifont.com/font/azukifont${downloadVersion}.zip";
    }
  ) fonts;

  meta = {
    description = "Azuki Font";
    homepage = "http://azukifont.com/font/azuki.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ nyadiia ];
    platforms = lib.platforms.all;
  };
}
