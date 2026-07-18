{
  lib,
  stdenv,
  fetchFromGitLab,
  graphicsmagick,
  vdr,
}:
stdenv.mkDerivation rec {
  pname = "vdr-skin-nopacity";
  version = "1.1.20";

  src = fetchFromGitLab {
    owner = "kamel5";
    repo = "SkinNopacity";
    tag = version;
    hash = "sha256-50oCb9xixPQEwv3Ni1UUmmWVzky/MTvZaqSUczhsHWc=";
  };

  buildInputs = [
    vdr
    graphicsmagick
  ];

  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    inherit (src.meta) homepage;
    inherit (vdr.meta) platforms;
    description = "Highly customizable native true color skin for the Video Disc Recorder";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.ck3d ];
  };
}
