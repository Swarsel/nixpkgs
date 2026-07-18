{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "asyncinotify";
  version = "4.4.4";

  src = fetchFromGitHub {
    owner = "absperf";
    repo = "asyncinotify";
    tag = "v${version}";
    hash = "sha256-NncqHS6JK9OYv/155PXYi0Sg4oX7p0WAGZ9wnvoYlgE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "asyncinotify" ];

  meta = {
    description = "Module for inotify";
    homepage = "https://github.com/absperf/asyncinotify/";
    changelog = "https://github.com/absperf/asyncinotify/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ cynerd ];

    badPlatforms = [
      # Unsupported and crashing on import in dlsym with symbol not found
      "aarch64-darwin"
    ];
  };
}
