{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fake-useragent";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "fake-useragent";
    repo = "fake-useragent";
    tag = version;
    hash = "sha256-CaFIXcS5y6m9mAfy4fniuA4VPTl6JfFq1WHnlLFz6fA=";
  };

  postPatch = ''
    sed -i '/addopts/d' pytest.ini
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = lib.optionals (pythonOlder "3.12") [
    "test_utils_load_pkg_resource_fallback"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fake_useragent" ];

  meta = {
    description = "Up to date simple useragent faker with real world database";
    homepage = "https://github.com/hellysmile/fake-useragent";
    changelog = "https://github.com/fake-useragent/fake-useragent/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evanjs ];
  };
}
