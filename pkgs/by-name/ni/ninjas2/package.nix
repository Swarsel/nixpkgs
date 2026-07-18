{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libjack2,
  libsamplerate,
  libsndfile,
  libx11,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ninjas2";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "clearly-broken-software";
    repo = "ninjas2";
    tag = "v${finalAttrs.version}";
    sha256 = "1kwp6pmnfar2ip9693gprfbcfscklgri1k1ycimxzlqr61nkd2k9";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libjack2
    libx11
    libGL
    libsndfile
    libsamplerate
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    install -dD bin/ninjas2.lv2 $out/lib/lv2/ninjas2.lv2
    install -D bin/ninjas2-vst.so  $out/lib/vst/ninjas2-vst.so
    install -D bin/ninjas2 $out/bin/ninjas2
  '';

  patchPhase = ''
    patchShebangs dpf/utils/generate-ttl.sh
  '';

  meta = {
    description = "Sample slicer plugin for LV2, VST, and jack standalone";
    homepage = "https://github.com/clearly-broken-software/ninjas2";
    license = with lib.licenses; [ gpl3 ];
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "ninjas2";
  };
})
