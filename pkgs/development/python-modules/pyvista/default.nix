{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cyclopts,
  matplotlib,
  numpy,
  pillow,
  pooch,
  scooby,
  setuptools,
  typing-extensions,
  vtk,
}:

buildPythonPackage rec {
  pname = "pyvista";
  version = "0.48.4";

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "pyvista";
    tag = "v${version}";
    hash = "sha256-VF84EMS/FnLl0y1LpWaYosyG0qEWI/QghZQq32ktlLg=";
  };

  # Fatal Python error: Aborted
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cyclopts
    matplotlib
    numpy
    pillow
    pooch
    scooby
    typing-extensions
    vtk
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvista" ];

  meta = {
    description = "Easier Pythonic interface to VTK";
    homepage = "https://pyvista.org";
    changelog = "https://github.com/pyvista/pyvista/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
