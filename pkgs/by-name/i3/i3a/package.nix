{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "i3a";
  version = "2.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-BcGAFFq3UEj4o7nNQ9aStueKmeDNIqSIqkYWhs2Tnqg=";
  };

  doCheck = false;

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
    python3Packages.hatchling
  ];

  dependencies = [ python3Packages.i3ipc ];
  pyproject = true;
  pythonImportsCheck = [ "i3a" ];

  meta = {
    description = "Set of scripts used for automation of i3 and sway window manager layouts";
    homepage = "https://git.goral.net.pl/i3a.git/about";
    changelog = "https://git.goral.net.pl/i3a.git/log/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      moni
      teohz
    ];

    broken = python3Packages.python.version < "3.11";
  };
})
