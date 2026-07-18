{
  lib,
  fetchFromGitHub,
  callPackage,
}:

callPackage ../generic.nix rec {
  pname = "tower-pixel-dungeon";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "FixAkaTheFix";
    repo = "Tower-Pixel-Dungeon";
    tag = "TPDv${lib.replaceStrings [ "." ] [ "" ] version}";
    hash = "sha256-/s+3FarO1iSW7f6SMkVxb9OSSEgVpM3gFUWFd+orcp4=";
  };

  patches = [ ];

  # Sprite sources (Paint.NET files) and other files interfere with the build process.
  postPatch = ''
    rm core/src/main/assets/{levelsplashes,sprites}/*.pdn
  '';

  desktopName = "Tower Pixel Dungeon";
  sourceRoot = src.name + "/pixel-towers-master";

  meta = {
    description = "Turn-based tower defense game based on Shattered Pixel Dungeon";
    homepage = "https://github.com/FixAkaTheFix/Tower-Pixel-Dungeon";
    downloadPage = "https://github.com/FixAkaTheFix/Tower-Pixel-Dungeon/releases";
  };
}
