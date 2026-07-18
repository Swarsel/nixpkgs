{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libconfig,
  libevdev,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "logiops";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "pixlone";
    repo = "logiops";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1v728hbIM2ODtB+r6SYzItczRJCsbuTvhYD2OUM1+/E=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    udev
    libevdev
    libconfig
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  meta = {
    description = "Unofficial userspace driver for HID++ Logitech devices";
    homepage = "https://github.com/PixlOne/logiops";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "logid";
  };
})
