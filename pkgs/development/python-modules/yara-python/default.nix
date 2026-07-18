{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  yara,
}:

buildPythonPackage rec {
  pname = "yara-python";
  version = "4.5.5";

  src = fetchFromGitHub {
    owner = "VirusTotal";
    repo = "yara-python";
    tag = "v${version}";
    hash = "sha256-3MElqZALdwmyUA7xTWp6mG8mhRJuUZbYTkvvQc4UfVc=";
  };

  # undefined symbol: yr_finalize
  # https://github.com/VirusTotal/yara-python/issues/7
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "include_dirs=['yara/libyara/include', 'yara/libyara/', '.']" "libraries = ['yara']"
  '';

  buildInputs = [ yara ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "yara" ];
  setupPyBuildFlags = [ "--dynamic-linking" ];

  meta = {
    description = "Python interface for YARA";
    homepage = "https://github.com/VirusTotal/yara-python";
    changelog = "https://github.com/VirusTotal/yara-python/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
