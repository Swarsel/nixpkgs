{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGo126Module,
  nixosTests,
}:

let
  hlsJs = fetchurl {
    hash = "sha256-QTqD4rsMd+0L8L4QXVOdF+9F39mEoLE+zTsUqQE4OTg=";
    url = "https://cdn.jsdelivr.net/npm/hls.js@v1.6.15/dist/hls.min.js";
  };
in
buildGo126Module (finalAttrs: {
  pname = "mediamtx";
  # check for hls.js version updates in internal/servers/hls/hlsjsdownloader/VERSION
  version = "1.18.2";

  src = fetchFromGitHub {
    owner = "bluenviron";
    repo = "mediamtx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qhW2q3PoOXBRtW4YXKMIYbQG4LypVLcSeV/uQ66hOgg=";
  };

  postPatch = ''
    cp ${hlsJs} internal/servers/hls/hls.min.js
    echo "v${finalAttrs.version}" > internal/core/VERSION

    # disable binary-only rpi camera support
    substituteInPlace internal/staticsources/rpicamera/camera_other.go \
      --replace-fail '!linux || (!arm && !arm64)' 'linux || !linux'
    substituteInPlace internal/staticsources/rpicamera/{params_serialize,pipe}.go \
      --replace-fail '(linux && arm) || (linux && arm64)' 'linux && !linux'
    substituteInPlace internal/staticsources/rpicamera/camera_arm32_.go \
      --replace-fail 'linux && arm' 'linux && !linux'
    substituteInPlace internal/staticsources/rpicamera/camera_arm64_.go \
      --replace-fail 'linux && arm64' 'linux && !linux'
    substituteInPlace internal/staticsources/rpicamera/camera_arm_.go \
      --replace-fail '(linux && arm) || (linux && arm64)' 'linux && !linux'
  '';

  vendorHash = "sha256-dWMwD1jG7+69d00T/T+7jY6MgodGuBpSBDwEHSGOKLQ=";
  # Tests need docker
  doCheck = false;
  subPackages = [ "." ];

  passthru.tests = {
    inherit (nixosTests) mediamtx;
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "SRT, WebRTC, RTSP, RTMP, LL-HLS media server and media proxy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fpletz ];
    mainProgram = "mediamtx";
  };
})
