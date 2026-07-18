{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fxrays";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "FXrays";
    tag = "${version}_as_released";
    hash = "sha256-IwEY54zDXqMci7WRvhueDJidTsbMwv6eqQSGZzFOtnQ";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m FXrays.test
    runHook postCheck
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "FXrays" ];

  meta = {
    description = "Computes extremal rays of polyhedral cones with filtering";
    homepage = "https://github.com/3-manifolds/FXrays";
    changelog = "https://github.com/3-manifolds/FXrays/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
