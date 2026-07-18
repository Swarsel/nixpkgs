{
  buildDunePackage,
  callPackage,
  dune-configurator,
  ffmpeg,
  ffmpeg-avutil,
  pkg-config,
  ffmpeg-base ? callPackage ./base.nix { },
}:

buildDunePackage {
  inherit (ffmpeg-base) version src;
  pname = "ffmpeg-avfilter";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ffmpeg-avutil
    ffmpeg.dev
  ];

  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = ffmpeg-base.meta // {
    description = "Bindings for the ffmpeg avfilter library";
  };

}
