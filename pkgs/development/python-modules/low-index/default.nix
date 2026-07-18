{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "low-index";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "low_index";
    tag = "v${version}_as_released";
    hash = "sha256-m3p05bqu70pMOsb9drW1B6+N893eBSZBFTNNS23OY6w=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m low_index.test
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "low_index" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.*)_as_released"
    ];
  };

  meta = {
    description = "Enumerates low index subgroups of a finitely presented group";
    homepage = "https://github.com/3-manifolds/low_index";
    changelog = "https://github.com/3-manifolds/low_index/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
