{
  fetchFromGitHub,
  callPackage,
  nixosTests,
}:

callPackage ./generic.nix rec {
  pname = "shattered-pixel-dungeon";
  version = "3.3.8";

  src = fetchFromGitHub {
    owner = "00-Evan";
    repo = "shattered-pixel-dungeon";
    tag = "v${version}";
    hash = "sha256-FRYuMjDk6UzmLeaR4MoONXYvNng7uC1xkxbDSiI3gnU=";
  };

  patches = [ ];
  depsPath = ./deps.json;
  desktopName = "Shattered Pixel Dungeon";

  passthru.tests = {
    shattered-pixel-dungeon-starts = nixosTests.shattered-pixel-dungeon;
  };

  meta = {
    description = "Traditional roguelike game with pixel-art graphics and simple interface";
    homepage = "https://shatteredpixel.com/";
    downloadPage = "https://github.com/00-Evan/shattered-pixel-dungeon/releases";
  };
}
