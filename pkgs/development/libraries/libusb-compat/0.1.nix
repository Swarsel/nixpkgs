{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libusb-compat";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "libusb";
    repo = "libusb-compat-0.1";
    rev = "v${version}";
    sha256 = "sha256-pAPERYSxoc47gwpPUoMkrbK8TOXyx03939vlFN0hHRg=";
  };

  outputs = [
    "out"
    "dev"
  ]; # get rid of propagating systemd closure

  patches = lib.optional stdenv.hostPlatform.isMusl ./fix-headers.patch;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libusb1 ];

  # without this, libusb-compat is unable to find libusb1
  postFixup = ''
    find $out/lib -name \*.so\* -type f -exec \
      patchelf --set-rpath ${lib.makeLibraryPath buildInputs} {} \;
  '';

  outputBin = "dev";

  meta = {
    description = "Cross-platform user-mode USB device library";

    longDescription = ''
      libusb is a cross-platform user-mode library that provides access to USB devices.
      The current API is of 1.0 version (libusb-1.0 API), this library is a wrapper exposing the legacy API.
    '';

    homepage = "https://libusb.info/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "libusb-config";
  };
}
