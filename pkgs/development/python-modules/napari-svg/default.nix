{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  imageio,
  napari-plugin-engine,
  numpy,
  setuptools,
  setuptools-scm,
  vispy,
}:

buildPythonPackage rec {
  pname = "napari-svg";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "napari";
    repo = "napari-svg";
    tag = "v${version}";
    hash = "sha256-m3lm+jXUuGr9WCxzo7VyZNcKadLPX2VrCC9obiSvreQ=";
  };

  # Circular dependency: napari
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    imageio
    napari-plugin-engine
    numpy
    vispy
  ];

  pyproject = true;

  meta = {
    description = "Plugin for writing svg files from napari";
    homepage = "https://github.com/napari/napari-svg";
    changelog = "https://github.com/napari/napari-svg/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
}
