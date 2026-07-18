{
  lib,
  fetchFromGitHub,
  buildGoModule,
  glib,
  gst_all_1,
  makeWrapper,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "livekit-ingress";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "livekit";
    repo = "ingress";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xg69NfsEWJEJcRcLBkMgBmCEIVhSe1wjxWxBbO1k1e0=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = with gst_all_1; [
    glib
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];

  vendorHash = "sha256-n8QT+wRCxFq9vcclsOnLjc0NG2NJTgo2ouqXedSdKvQ=";
  # there are no actual tests, and we don't need to spend
  # another 5 minutes of cgo to figure that out
  doCheck = false;

  postInstall = ''
    mv $out/bin/server $out/bin/ingress
    wrapProgram $out/bin/ingress --suffix GST_PLUGIN_SYSTEM_PATH_1_0 ":" $GST_PLUGIN_SYSTEM_PATH_1_0
  '';

  subPackages = [ "cmd/server" ];

  meta = {
    description = "Ingest streams (RTMP/WHIP) or files (HLS, MP4) to LiveKit WebRTC";
    homepage = "https://github.com/livekit/ingress";
    changelog = "https://github.com/livekit/ingress/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ k900 ];
    mainProgram = "ingress";
  };
})
