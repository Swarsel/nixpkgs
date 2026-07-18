{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  freetype,
  ftgl,
  libGL,
  libGLU,
  libjack2,
  libx11,
  lv2,
  nix-update-script,
  pkg-config,
  ttf_bitstream_vera,
}:
let
  version = "0.8.13";
in
stdenv.mkDerivation {
  inherit version;
  pname = "setbfree";

  src = fetchFromGitHub {
    owner = "pantherb";
    repo = "setBfree";
    rev = "v${version}";
    hash = "sha256-jtiyJntaFnAVeC1Rvkzi3wNodyJpEQKgnOAP7++36wo=";
  };

  postPatch = ''
    substituteInPlace common.mak \
      --replace /usr/local "$out" \
      --replace /usr/share/fonts/truetype/ttf-bitstream-vera "${ttf_bitstream_vera}/share/fonts/truetype"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    freetype
    ftgl
    libjack2
    libx11
    lv2
    libGLU
    libGL
    ttf_bitstream_vera
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    (
      set -x;
      test -e $out/bin/setBfreeUI
    )
  '';

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "DSP tonewheel organ emulator";
    homepage = "https://setbfree.org";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.l1npengtul ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ]; # fails on ARM and Darwin

    broken = stdenv.hostPlatform.isAarch64;
  };
}
