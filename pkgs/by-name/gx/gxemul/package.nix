{
  lib,
  stdenv,
  fetchurl,
  libx11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gxemul";
  version = "0.7.0";

  src = fetchurl {
    url = "https://gavare.se/gxemul/src/gxemul-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-ecRDfG+MqQT0bTOsNgYqZf3PSpKiSEeOQIqxEpXPjoM=";
  };

  patches = [
    # Fix compilation; remove when next release arrives
    ./0001-fix-attributes.patch
  ];

  buildInputs = [
    libx11
  ];

  preConfigure = ''
    export PREFIX=${placeholder "out"}
  '';

  dontAddPrefix = true;

  meta = {
    description = "Gavare's experimental emulator";

    longDescription = ''
      GXemul is a framework for full-system computer architecture
      emulation. Several real machines have been implemented within the
      framework, consisting of processors (ARM, MIPS, Motorola 88K, PowerPC, and
      SuperH) and surrounding hardware components such as framebuffers,
      interrupt controllers, busses, disk controllers, and serial
      controllers. The emulation is working well enough to allow several
      unmodified "guest" operating systems to run.
    '';

    homepage = "https://gavare.se/gxemul/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gxemul";
  };
})
