{
  lib,
  stdenv,
  kernel,
}:

stdenv.mkDerivation {
  inherit (kernel) src version;
  pname = "iio-utils";

  postPatch = ''
    cd tools/iio
  '';

  makeFlags = [ "bindir=${placeholder "out"}/bin" ];

  meta = {
    description = "Userspace tool for interacting with Linux IIO";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
