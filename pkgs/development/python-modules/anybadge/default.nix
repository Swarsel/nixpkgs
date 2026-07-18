{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pytestCheckHook,
  requests,
  setuptools,
  sh,
}:

buildPythonPackage rec {
  pname = "anybadge";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "jongracecox";
    repo = "anybadge";
    tag = "v${version}";
    hash = "sha256-9qGmiIGzVdWHMyurMqTqEz+NKYlc/5zt6HPsssCH4Pk=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '=get_version(),' "='$version',"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    requests
    sh
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    packaging
  ];

  disabledTestPaths = [
    # No anybadge-server
    "tests/test_server.py"
  ];

  disabledTests = [
    # Comparison of CLI output fails
    "test_module_same_output_as_main_cli"
  ];

  pyproject = true;
  pythonImportsCheck = [ "anybadge" ];

  meta = {
    description = "Python tool for generating badges for your projects";
    homepage = "https://github.com/jongracecox/anybadge";
    changelog = "https://github.com/jongracecox/anybadge/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
