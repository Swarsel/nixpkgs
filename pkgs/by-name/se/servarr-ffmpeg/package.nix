{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  ffmpeg-headless,
}:

let
  version = "5.1.10";
in

(ffmpeg-headless.override {
  inherit version; # Important! This sets the ABI.
  buildAvdevice = false;
  buildAvfilter = false;
  buildFfmpeg = false;
  buildFfplay = false;
  buildPostproc = false;
  buildSwresample = false;
  buildSwscale = false;

  # Fetch commit hash from this repository: https://github.com/Servarr/ffmpeg-build
  # Compare build logs to upstream logs here: https://dev.azure.com/Servarr/Servarr/_build?definitionId=15
  source = fetchFromGitHub {
    hash = "sha256-8qXQIbBNFRX3HsEHD2m4STHyxALqTSoIkKrVLc6vX/4=";
    owner = "Servarr";
    repo = "FFmpeg";
    rev = "9eecad42d64ab888b9bb366df998b5b7cac0e2bc";
  };

  withAlsa = false;
  withAmf = false;
  withAom = false;
  withAss = false;
  withBluray = false;
  withBzlib = false;
  withCudaLLVM = false;
  withCuvid = false;
  withDrm = false;
  withFontconfig = false;
  withFreetype = false;
  withFribidi = false;
  withGmp = false;
  withGnutls = false;
  withIconv = false;
  withLzma = false;
  withMp3lame = false;
  withNetwork = false;
  withNvcodec = false;
  withOpencl = false;
  withOpenjpeg = false;
  withOpenmpt = false;
  withOpus = false;
  withRist = false;
  withSoxr = false;
  withSpeex = false;
  withSrt = false;
  withSsh = false;
  withSvtav1 = false;
  withTheora = false;
  withV4l2 = false;
  withVaapi = false;
  withVidStab = false;
  withVorbis = false;
  withVpx = false;
  withVulkan = false;
  withWebp = false;
  withX264 = false;
  withX265 = false;
  withXml2 = false;
  withXvid = false;
  withZimg = false;
  withZlib = false;
  withZvbi = false;
}).overrideAttrs
  (old: {
    pname = "servarr-ffmpeg";

    patches = old.patches ++ [
      (fetchpatch2 {
        hash = "sha256-+2kzfPJf5piim+DqEgDuVEEX5HLwRsxq0dWONJ4ACrU=";
        name = "fix_build_failure_due_to_libjxl_version_to_new";
        url = "https://git.ffmpeg.org/gitweb/ffmpeg.git/patch/75b1a555a70c178a9166629e43ec2f6250219eb2";
      })
    ];

    configureFlags = old.configureFlags ++ [
      "--extra-version=Servarr"

      # https://github.com/Servarr/ffmpeg-build/blob/bc29af6f0bf84bf9253d4d462611b1dc31ee688e/common.sh#L15-L45

      # Disable unused functionnalities
      "--disable-encoders"
      "--disable-muxers"
      "--disable-protocols"
      "--disable-bsfs"

      # FFMpeg options - enable what we need
      "--enable-protocol=file"
      "--enable-bsf=av1_frame_split"
      "--enable-bsf=av1_frame_merge"
      "--enable-bsf=av1_metadata"
    ];

    doCheck = false;

    meta = {
      inherit (old.meta) license pkgConfigModules;
      description = "${old.meta.description} (Servarr fork)";
      homepage = "https://github.com/Servarr/FFmpeg";
      maintainers = with lib.maintainers; [ nyanloutre ];
      mainProgram = "ffprobe";
    };
  })
