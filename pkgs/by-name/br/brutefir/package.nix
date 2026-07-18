{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fftw,
  fftwFloat,
  flex,
  libjack2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brutefir";
  version = "1.0o";

  src = fetchurl {
    url = "https://torger.se/anders/files/brutefir-${finalAttrs.version}.tar.gz";
    sha256 = "caae4a933b53b55b29d6cb7e2803e20819f31def6d0e4e12f9a48351e6dbbe9f";
  };

  postPatch = "substituteInPlace bfconf.c --replace /usr/local $out";
  nativeBuildInputs = [ flex ];

  buildInputs = [
    alsa-lib
    fftw
    fftwFloat
    libjack2
  ];

  installFlags = [ "INSTALL_PREFIX=$(out)" ];

  meta = {
    description = "Software convolution engine";
    homepage = "https://torger.se/anders/brutefir.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ auchter ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "brutefir";
  };
})
