{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bashlex";
  version = "0.18";

  src = fetchFromGitHub {
    owner = "idank";
    repo = "bashlex";
    tag = finalAttrs.version;
    hash = "sha256-ddZN91H95RiTLXx4lpES1Dmz7nNsSVUeuFuOEpJ7LQI=";
  };

  # workaround https://github.com/idank/bashlex/issues/51
  preBuild = ''
    ${python.pythonOnBuildForHost.interpreter} -c 'import bashlex'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bashlex" ];

  meta = {
    description = "Python parser for bash";
    homepage = "https://github.com/idank/bashlex";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ multun ];
  };
})
