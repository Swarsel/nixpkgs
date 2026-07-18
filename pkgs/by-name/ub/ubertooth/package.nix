{
  lib,
  stdenv,
  fetchFromGitHub,
  bluez,
  cmake,
  libbtbb,
  libpcap,
  libusb1,
  pkg-config,
  udevGroup ? "ubertooth",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ubertooth";
  version = "2020-12-R1";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "ubertooth";
    rev = finalAttrs.version;
    sha256 = "11r5ag2l5xn4pr7ycicm30w9c3ldn9yiqj1sqnjc79csxl2vrcfw";
  };

  patches = [
    # https://github.com/greatscottgadgets/ubertooth/pull/546
    ./fix-cmake4-build.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libbtbb
    libpcap
    libusb1
    bluez
  ];

  cmakeFlags = lib.optionals stdenv.hostPlatform.isLinux [
    "-DINSTALL_UDEV_RULES=TRUE"
    "-DUDEV_RULES_PATH=etc/udev/rules.d"
    "-DUDEV_RULES_GROUP=${udevGroup}"
  ];

  doInstallCheck = true;
  sourceRoot = "${finalAttrs.src.name}/host";

  meta = {
    description = "Open source wireless development platform suitable for Bluetooth experimentation";
    homepage = "https://github.com/greatscottgadgets/ubertooth";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
