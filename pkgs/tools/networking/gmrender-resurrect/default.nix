{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gst-libav,
  gst-plugins-bad,
  gst-plugins-base,
  gst-plugins-good,
  gst-plugins-ugly,
  gstreamer,
  libupnp,
  makeWrapper,
  pkg-config,
}:

let
  version = "0.3.1";

  pluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
in
stdenv.mkDerivation {
  inherit version;
  pname = "gmrender-resurrect";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = "gmrender-resurrect";
    rev = "v${version}";
    sha256 = "sha256-e8X/Ab4E6FmPpbRx4y8UZbuPTFaq2hz4Ye8dbKTqGUc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    gstreamer
    libupnp
  ];

  postInstall = ''
    for prog in "$out/bin/"*; do
        wrapProgram "$prog" --suffix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pluginPath}"
    done
  '';

  meta = {
    description = "Resource efficient UPnP/DLNA renderer, optimal for Raspberry Pi, CuBox or a general MediaServer";
    homepage = "https://github.com/hzeller/gmrender-resurrect";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      koral
      hzeller
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gmediarender";
  };
}
