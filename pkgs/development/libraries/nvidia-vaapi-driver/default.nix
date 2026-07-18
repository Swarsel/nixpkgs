{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  gst_all_1,
  libGL,
  libdrm,
  libva,
  meson,
  ninja,
  nv-codec-headers-11,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "nvidia-vaapi-driver";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "elFarto";
    repo = "nvidia-vaapi-driver";
    rev = "v${version}";
    sha256 = "sha256-eJ523lEmB4s+R/QN4J8t6LZ4zw2rEQsaaRBJdjH8Amo=";
  };

  patches = [
    ./0001-hardcode-install_dir.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    addDriverRunpath
  ];

  buildInputs = [
    libdrm
    libGL
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    nv-codec-headers-11
    libva
  ];

  postFixup = ''
    addDriverRunpath "$out/lib/dri/nvidia_drv_video.so"
  '';

  meta = {
    description = "VA-API implemention using NVIDIA's NVDEC";
    homepage = "https://github.com/elFarto/nvidia-vaapi-driver";
    changelog = "https://github.com/elFarto/nvidia-vaapi-driver/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
