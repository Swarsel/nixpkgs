{
  lib,
  libcapsicum,
  libcasper,
  libnv,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libcasper
    libcapsicum
    libnv
  ];

  # These want to install some config files which we don't want
  MK_FTP = "no";
  MK_LPR = "no";
  MK_PPP = "no";
  MK_TESTS = "no";

  extraPaths = [
    "usr.bin/wall"
    "sys/sys"
  ];

  path = "usr.sbin/syslogd";

  meta = {
    description = "FreeBSD syslog daemon";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ artemist ];
    platforms = lib.platforms.freebsd;
  };
}
