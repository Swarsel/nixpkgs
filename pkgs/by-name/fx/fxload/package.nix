{
  lib,
  stdenv,
  libusb1,
}:

stdenv.mkDerivation rec {
  pname = "fxload";
  version = libusb1.version;

  # fxload binary exist inside the `examples/bin` directory of `libusb1`
  postFixup = ''
    mkdir -p $out/bin
    ln -s ${passthru.libusb}/examples/bin/fxload $out/bin/fxload
  '';

  dontBuild = true;
  dontConfigure = true;
  dontInstall = true;
  dontPatch = true;
  dontPatchELF = true;
  dontUnpack = true;
  passthru.libusb = libusb1.override { withExamples = true; };

  meta = {
    description = "Tool to upload firmware to into an21, fx, fx2, fx2lp and fx3 ez-usb devices";
    homepage = "https://github.com/libusb/libusb";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ logger ];
    platforms = lib.platforms.linux;
    mainProgram = "fxload";
  };
}
