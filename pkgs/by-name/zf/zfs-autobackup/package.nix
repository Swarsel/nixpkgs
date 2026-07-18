{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "zfs-autobackup";
  version = "3.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-nAc1mdrtIEmUS0uMqOdvV07xP02MFj6F5uCTiCXtnMs=";
    pname = "zfs_autobackup";
  };

  # tests need zfs filesystem
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "zfs_autobackup" ];
  pythonRemoveDeps = [ "argparse" ];

  meta = {
    description = "ZFS backup, replicationand snapshot tool";
    homepage = "https://github.com/psy0rz/zfs_autobackup";
    changelog = "https://github.com/psy0rz/zfs_autobackup/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
})
