{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "knot-floer-homology";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "knot_floer_homology";
    tag = "${version}_as_released";
    hash = "sha256-Gw9k9AaUVTBzE+ERUH8VgS//aVT03DdKozpL8xLG4No=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m knot_floer_homology.test
    runHook postCheck
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "knot_floer_homology" ];

  meta = {
    description = "Python wrapper for Zoltán Szabó's HFK Calculator";
    homepage = "https://github.com/3-manifolds/knot_floer_homology";
    changelog = "https://github.com/3-manifolds/knot_floer_homology/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
