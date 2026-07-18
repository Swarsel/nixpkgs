{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "raiseorlaunch";
  version = "2.3.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-L/hu0mYCAxHkp5me96a6HlEY6QsuJDESpTNhlzVRHWs=";
  };

  # no tests
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "raiseorlaunch" ];
  pythonPath = with python3Packages; [ i3ipc ];

  meta = {
    description = "Run-or-raise-application-launcher for i3 window manager";
    homepage = "https://github.com/open-dynaMIX/raiseorlaunch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ winpat ];
    platforms = lib.platforms.linux;
    mainProgram = "raiseorlaunch";
  };
})
