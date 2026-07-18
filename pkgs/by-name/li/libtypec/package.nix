{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3, # utils
  libudev0-shim,
  libusb1,
  meson,
  ninja,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "libtypec";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "libtypec";
    repo = "libtypec";
    rev = "libtypec-${version}";
    hash = "sha256-XkT0bgBjoJTAFa9NLZdzbJSpchiXxKjeu88PeT/AlPY=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libusb1
    libudev0-shim
    systemd
    gtk3
  ];

  mesonFlags = [
    (lib.mesonBool "utils" true)
    "--prefix=${placeholder "dev"}"
  ];

  # Don't propagate out to the dev output to avoid pulling in GUI dependencies
  propagatedBuildOutputs = [ "lib" ];

  meta = with lib; {
    description = "generic diagnostic tool interface for usb-c ports";
    longDescription = "libtypec is aimed to provide a generic interface abstracting all platform complexity for user space to develop tools for efficient USB-C port management. The library can also enable development of diagnostic and debug tools to debug system issues around USB-C/USB PD topology.";
    homepage = "https://github.com/libtypec/libtypec";

    license = with licenses; [
      mit
      gpl2Only
    ];

    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.linux;
  };
}
