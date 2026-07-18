{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "btrfs";
  version = "15";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-FBmRT/FB3+nhb9BHfZVI1L6nM+zXdYjoy3JVzhetoQs=";
  };

  # currently no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "btrfs" ];

  meta = {
    description = "Inspect btrfs filesystems";
    homepage = "https://github.com/knorrie/python-btrfs";
    changelog = "https://github.com/knorrie/python-btrfs/blob/v${finalAttrs.version}/CHANGES";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      Luflosi
    ];

    platforms = lib.platforms.linux;
  };
})
