{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pytestCheckHook,
  python-slugify,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-nvd3";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "areski";
    repo = "python-nvd3";
    tag = "v${version}";
    hash = "sha256-+J0lHAOjX3hbymjESQ6WpEnly+1Lv9o0ucIpBxTuS6s=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    python-slugify
    jinja2
  ];

  enabledTestPaths = [ "tests.py" ];
  pyproject = true;

  meta = {
    description = "Python Wrapper for NVD3";
    homepage = "https://github.com/areski/python-nvd3";
    changelog = "https://github.com/areski/python-nvd3/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "nvd3";
  };
}
