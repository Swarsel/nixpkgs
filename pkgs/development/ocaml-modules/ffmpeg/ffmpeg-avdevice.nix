{
  buildDunePackage,
  callPackage,
  dune-configurator,
  ffmpeg,
  ffmpeg-av,
  pkg-config,
  ffmpeg-base ? callPackage ./base.nix { },
}:

buildDunePackage {
  inherit (ffmpeg-base) version src;
  pname = "ffmpeg-avdevice";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ffmpeg-av
    ffmpeg.dev
  ];

  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = ffmpeg-base.meta // {
    description = "Bindings for the ffmpeg avdevice library";
  };

}
