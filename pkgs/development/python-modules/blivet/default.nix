{
  lib,
  fetchFromGitHub,
  btrfs-progs,
  buildPythonPackage,
  bytesize,
  cryptsetup,
  dasbus,
  dbus-python,
  dosfstools,
  dracut,
  e2fsprogs,
  f2fs-tools,
  gfs2-utils,
  hfsprogs,
  kmod,
  libblockdev,
  libndctl,
  lvm2,
  mdadm,
  multipath-tools,
  ntfs3g,
  nvme-cli,
  pkgs,
  pygobject3,
  python,
  pyudev,
  stratisd,
  util-linux,
  xfsprogs,
}:

let
  libblockdevPython = (libblockdev.override { python3 = python; }).python;
in
buildPythonPackage rec {
  pname = "blivet";
  version = "3.13.2";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "blivet";
    tag = "blivet-${version}";
    hash = "sha256-Yq8lIgu2S4L2PNeJ+ybn6daaPA2XlDJkUPihHiH2n+w=";
  };

  postPatch = ''
    find blivet -name '*.py' | while IFS= read -r i ; do
      substituteInPlace "$i" \
        --replace \
          'gi.require_version("BlockDev",' \
          'import gi.repository
    gi.require_version("GIRepository", "3.0")
    from gi.repository import GIRepository
    GIRepository.Repository.dup_default().prepend_search_path("${libblockdev}/lib/girepository-1.0")
    gi.require_version("BlockDev",'
    done
  '';

  propagatedBuildInputs = [
    pygobject3
    libblockdevPython
    bytesize
    dasbus
    pyudev
    dbus-python
    util-linux
    kmod
    libndctl
    nvme-cli
    pkgs.systemd
    dosfstools
    e2fsprogs
    hfsprogs
    xfsprogs
    f2fs-tools
    ntfs3g
    btrfs-progs
    mdadm
    lvm2
    gfs2-utils
    cryptsetup
    multipath-tools
    dracut
    stratisd
  ];

  # Even unit tests require a system D-Bus.
  # TODO: Write a NixOS VM test?
  doCheck = false;
  format = "setuptools";

  pythonImportsCheck = [
    "blivet"
    "blivet.devicelibs.lvm"
  ];

  meta = {
    description = "Python module for system storage configuration";
    homepage = "https://github.com/storaged-project/blivet";

    license = [
      lib.licenses.gpl2Plus
      lib.licenses.lgpl2Plus
    ];

    maintainers = with lib.maintainers; [ cybershadow ];
    platforms = lib.platforms.linux;
  };
}
