{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  sg3_utils,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ledmon";
  version = "0.92";

  src = fetchFromGitHub {
    owner = "md-raid-utilities";
    repo = "ledmon";
    rev = "v${finalAttrs.version}";
    sha256 = "1lz59606vf2sws5xwijxyffm8kxcf8p9qbdpczsq1b5mm3dk6lvp";
  };

  nativeBuildInputs = [
    perl # for pod2man
  ];

  buildInputs = [
    udev
    sg3_utils
  ];

  makeFlags = [
    "MAN_INSTDIR=${placeholder "out"}/share/man"
    "SYSTEMD_SERVICE_INSTDIR=${placeholder "out"}/lib/systemd/system"
    "LEDCTL_INSTDIR=${placeholder "out"}/sbin"
    "LEDMON_INSTDIR=${placeholder "out"}/sbin"
  ];

  installTargets = [
    "install"
    "install-systemd"
  ];

  meta = {
    description = "Enclosure LED Utilities";
    homepage = "https://github.com/md-raid-utilities/ledmon";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ sorki ];
    platforms = lib.platforms.linux;
  };
})
