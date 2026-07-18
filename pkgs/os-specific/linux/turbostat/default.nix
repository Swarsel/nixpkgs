{
  lib,
  stdenv,
  kernel,
  libcap,
}:

stdenv.mkDerivation {
  inherit (kernel) src version;
  pname = "turbostat";

  postPatch = ''
    cd tools/power/x86/turbostat
  '';

  buildInputs = [ libcap ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Report processor frequency and idle statistics";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ]; # x86-specific

    mainProgram = "turbostat";
  };
}
