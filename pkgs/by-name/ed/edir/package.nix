{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "edir";
  version = "2.32";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-E9zb7Y4KNQ/gw+TkpRVMUHMPlY1ImQAb0P8G/OFgMwM=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools-scm
  ];

  propagatedBuildInputs = with python3Packages; [
    platformdirs
  ];

  pyproject = true;

  meta = {
    description = "Program to rename and remove files and directories using your editor";
    homepage = "https://github.com/bulletmark/edir";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ guyonvarch ];
    platforms = lib.platforms.all;
    mainProgram = "edir";
  };
})
