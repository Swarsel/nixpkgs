{
  lib,
  autoreconfHook,
  btrfs-progs,
  buildPythonPackage,
  e2fsprogs,
  libuuid,
  pkg-config,
  setuptools,
  zlib,
}:
buildPythonPackage {
  inherit (btrfs-progs) version src;
  pname = "btrfsutil";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    btrfs-progs
    e2fsprogs
    libuuid
    zlib
  ];

  configureFlags = [
    "--disable-documentation"
    "--disable-zstd"
    "--disable-lzo"
    "--disable-libudev"
  ];

  preBuild = ''
    cd libbtrfsutil/python
  '';

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "btrfsutil" ];

  meta = {
    description = "Library for managing Btrfs filesystems";
    homepage = "https://btrfs.readthedocs.io/";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      raskin
      lopsided98
    ];
  };
}
