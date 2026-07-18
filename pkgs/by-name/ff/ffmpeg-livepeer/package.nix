{
  lib,
  fetchFromGitHub,
  ffmpeg_7-headless,
}:

(ffmpeg_7-headless.override {
  version = "7.0.1-unstable-2024-07-10";

  source = fetchFromGitHub {
    hash = "sha256-IJVpb/k+obGFD9uOoIVHCd2ZiGL3CA4CV3D+Q9vMbQM=";
    owner = "livepeer";
    repo = "FFmpeg";
    rev = "d9751c73e714b01b363483db358b1ea8022c9bea"; # From branch n*-livepeer
  };

  withCudaLLVM = true;
}).overrideAttrs
  (old: {
    pname = "ffmpeg-livepeer";

    postPatch = (old.postPatch or "") + ''
            substituteInPlace libavcodec/tableprint_vlc.h \
              --replace-fail 'define av_mallocz(s) NULL' 'define av_mallocz(s) NULL
      #define av_malloc(s) NULL'
    '';

    meta = {
      inherit (old.meta)
        license
        mainProgram
        pkgConfigModules
        platforms
        ;

      maintainers = with lib.maintainers; [ bot-wxt1221 ];
    };
  })
