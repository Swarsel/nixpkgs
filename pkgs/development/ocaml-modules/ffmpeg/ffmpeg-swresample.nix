{
  buildDunePackage,
  callPackage,
  dune-configurator,
  ffmpeg,
  ffmpeg-avcodec,
  ffmpeg-avutil,
  pkg-config,
  ffmpeg-base ? callPackage ./base.nix { },
}:

buildDunePackage {
  inherit (ffmpeg-base) version src;
  pname = "ffmpeg-swresample";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ffmpeg-avutil
    ffmpeg-avcodec
    ffmpeg.dev
  ];

  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = ffmpeg-base.meta // {
    description = "Bindings for the ffmpeg swresample library";
  };

}
