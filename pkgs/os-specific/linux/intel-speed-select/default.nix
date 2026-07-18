{
  lib,
  stdenv,
  kernel,
}:

stdenv.mkDerivation {
  inherit (kernel) src version;
  pname = "intel-speed-select";

  postPatch = ''
    cd tools/power/x86/intel-speed-select
    sed -i 's,/usr,,g' Makefile
  '';

  makeFlags = [ "bindir=${placeholder "out"}/bin" ];

  meta = {
    description = "Tool to enumerate and control the Intel Speed Select Technology features";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ]; # x86-specific

    mainProgram = "intel-speed-select";
    broken = kernel.kernelAtLeast "5.18";
  };
}
