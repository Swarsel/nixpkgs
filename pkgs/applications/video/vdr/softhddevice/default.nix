{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  ffmpeg,
  libGL,
  libGLU,
  libva,
  libvdpau,
  libx11,
  libxcb,
  libxcb-wm,
  vdr,
  xorg-server,
}:
stdenv.mkDerivation rec {
  pname = "vdr-softhddevice";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "ua0lnj";
    repo = "vdr-plugin-softhddevice";
    rev = "v${version}";
    sha256 = "sha256-vicHneEZZHTraffUek77QDZdv/xZGzN102nbr1Bkfzo=";
  };

  postPatch = ''
    substituteInPlace softhddev.c \
      --replace "LOCALBASE \"/bin/X\"" "\"${xorg-server}/bin/X\""
  '';

  buildInputs = [
    vdr
    libxcb-wm
    ffmpeg
    alsa-lib
    libva
    libvdpau
    libxcb
    libx11
    libGL
    libGLU
  ];

  makeFlags = [ "DESTDIR=$(out)" ];

  meta = {
    inherit (src.meta) homepage;
    inherit (vdr.meta) platforms;
    description = "VDR SoftHDDevice Plug-in";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.ck3d ];
  };

}
