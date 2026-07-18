{
  lib,
  stdenv,
  fetchurl,
  gd,
  libv4l,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fswebcam";
  version = "20200725";

  src = fetchurl {
    url = "https://www.sanslogic.co.uk/fswebcam/files/fswebcam-${finalAttrs.version}.tar.gz";
    sha256 = "1dazsrcaw9s30zz3jpxamk9lkff5dkmflp1s0jjjvdbwa0k6k6ii";
  };

  buildInputs = [
    libv4l
    gd
  ];

  meta = {
    description = "Neat and simple webcam app";
    homepage = "http://www.sanslogic.co.uk/fswebcam";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "fswebcam";
  };
})
