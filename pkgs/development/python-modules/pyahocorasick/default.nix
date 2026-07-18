{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyahocorasick";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "WojciechMula";
    repo = "pyahocorasick";
    tag = "v${version}";
    hash = "sha256-lExpRJlRoYS45Bw9FQwa7GKELBljKA83ZhXg7e5vPwM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ahocorasick" ];

  meta = {
    description = "Python module implementing Aho-Corasick algorithm";

    longDescription = ''
      This Python module is a fast and memory efficient library for exact or
      approximate multi-pattern string search meaning that you can find multiple
      key strings occurrences at once in some input text.
    '';

    homepage = "https://github.com/WojciechMula/pyahocorasick";
    changelog = "https://github.com/WojciechMula/pyahocorasick/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
