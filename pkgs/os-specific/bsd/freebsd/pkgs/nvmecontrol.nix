{
  libnv,
  libnvmf,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    libnvmf
    libnv
    libsbuf
  ];

  MK_TESTS = "no";

  extraPaths = [
    "sys/dev/nvme"
  ];

  path = "sbin/nvmecontrol";
}
