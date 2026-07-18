{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyosf";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "psychopy";
    repo = "pyosf";
    tag = "v${version}";
    hash = "sha256-Yhb6HSnLdFzWouse/RKZ8SIbMia/hhD8TAovdqmvd7o=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner', " ""
  '';

  preBuild = "export HOME=$TMP";
  # Tests require network access
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pyosf" ];

  meta = {
    description = "Pure Python library for simple sync with Open Science Framework";
    homepage = "https://github.com/psychopy/pyosf";
    changelog = "https://github.com/psychopy/pyosf/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
