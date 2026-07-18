{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoreconfHook,
  cmrt,
  libGL,
  libdrm,
  libva,
  libx11,
  pkg-config,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-hybrid-driver";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-hybrid-driver";
    rev = finalAttrs.version;
    sha256 = "sha256-uYX7RoU1XVzcC2ea3z/VBjmT47xmzK67Y4LaiFXyJZ8=";
  };

  patches = [
    # driver_init: load libva-x11.so for any ABI version
    (fetchurl {
      sha256 = "1ql4mbi5x1d2a5c8mkjvciaq60zj8nhx912992winbhfkyvpb3gx";
      url = "https://github.com/01org/intel-hybrid-driver/pull/26.diff";
    })
  ];

  postPatch = ''
    patchShebangs ./src/shaders/gpp.py
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    cmrt
    libdrm
    libva
    libx11
    libGL
    wayland
  ];

  configureFlags = [
    "--enable-drm"
    "--enable-x11"
    "--enable-wayland"
  ];

  # Workaround build failure on -fno-common toolchains like upstream gcc-10.
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  preConfigure = ''
    sed -i -e "s,LIBVA_DRIVERS_PATH=.*,LIBVA_DRIVERS_PATH=$out/lib/dri," configure
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Intel driver for the VAAPI library with partial HW acceleration";
    homepage = "https://01.org/linuxmedia";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tadfisher ];
    platforms = lib.platforms.linux;
  };
})
