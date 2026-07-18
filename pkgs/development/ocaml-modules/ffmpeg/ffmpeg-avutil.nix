{
  lib,
  buildDunePackage,
  callPackage,
  dune-configurator,
  ffmpeg,
  pkg-config,
  ffmpeg-base ? callPackage ./base.nix { },
}:

buildDunePackage {
  inherit (ffmpeg-base) version src;
  pname = "ffmpeg-avutil";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ ffmpeg.dev ];
  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = ffmpeg-base.meta // {
    description = "Bindings for the ffmpeg avutil libraries";
  };

}
