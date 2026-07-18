{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "i3altlayout";
  version = "0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-DhOYeSCxKthr2fEMGMBXjUYeCJjj6AV4d05So4eDF8A=";
  };

  doCheck = false;
  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "i3altlayout" ];

  pythonPath = with python3Packages; [
    i3ipc
    docopt
  ];

  pythonRemoveDeps = [ "enum-compat" ];

  meta = {
    description = "Helps you handle more efficiently your screen real estate in i3wm by auto-splitting windows on their longest side";
    homepage = "https://github.com/deadc0de6/i3altlayout";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "i3altlayout";
  };
})
