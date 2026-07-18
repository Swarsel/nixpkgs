{
  buildDunePackage,
  callPackage,
  ffmpeg-av,
  ffmpeg-avcodec,
  ffmpeg-avdevice,
  ffmpeg-avfilter,
  ffmpeg-avutil,
  ffmpeg-swresample,
  ffmpeg-swscale,
  ffmpeg-base ? callPackage ./base.nix { },
}:

buildDunePackage {
  inherit (ffmpeg-base) version src;
  pname = "ffmpeg";

  propagatedBuildInputs = [
    ffmpeg-avutil
    ffmpeg-avcodec
    ffmpeg-avfilter
    ffmpeg-swscale
    ffmpeg-swresample
    ffmpeg-av
    ffmpeg-avdevice
  ];

  # The tests fail
  doCheck = false;
  minimalOCamlVersion = "4.12";

  meta = ffmpeg-base.meta // {
    description = "Bindings for the ffmpeg libraries";
  };

}
