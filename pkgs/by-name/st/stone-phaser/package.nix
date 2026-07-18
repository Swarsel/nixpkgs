{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libGL,
  libgbm,
  libjack2,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stone-phaser";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "jpcima";
    repo = "stone-phaser";
    rev = "v${finalAttrs.version}";
    sha256 = "180b32z8h9zi8p0q55r1dzxfckamnngm52zjypjjvvy7qdj3mfcd";
    fetchSubmodules = true;
  };

  postPatch = ''
    patch -d dpf -p 1 -i "$src/resources/patch/DPF-bypass.patch"
    patchShebangs ./dpf/utils/generate-ttl.sh

    # Fix gcc-13 build failure due to missing includes
    sed -e '1i #include <cstdint>' -i plugins/stone-phaser/ui/Color.h
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    libGL
    lv2
    libjack2
    libgbm
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Classic analog phaser effect, made with DPF and Faust";
    homepage = "https://github.com/jpcima/stone-phaser";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
