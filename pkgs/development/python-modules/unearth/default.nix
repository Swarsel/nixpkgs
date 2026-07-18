{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  flask,
  httpx,
  packaging,
  pdm-backend,
  pytest-httpserver,
  pytest-mock,
  pytestCheckHook,
  requests-wsgi-adapter,
  trustme,
}:

buildPythonPackage rec {
  pname = "unearth";
  version = "0.18.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HlPX9S9G3V+HXnf/HFWxJHfiFaCS5LZsl2SnffSptSA=";
  };

  patches = [
    # https://github.com/frostming/unearth/pull/176
    (fetchpatch {
      excludes = [ "pdm.lock" ];
      hash = "sha256-t/Ubv9qC1Fvh4JsnfVgOZO/O7ZpCGHugBUt9qAjnH8c=";
      name = "fix-packaging-26.0-changes.patch";
      url = "https://github.com/frostming/unearth/commit/69ece0800edeefb1daf035bb0ee348e17a4393fd.patch";
    })
  ];

  nativeCheckInputs = [
    flask
    pytest-httpserver
    pytest-mock
    pytestCheckHook
    requests-wsgi-adapter
    trustme
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ pdm-backend ];

  dependencies = [
    packaging
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "unearth" ];

  meta = {
    description = "Utility to fetch and download Python packages";
    homepage = "https://github.com/frostming/unearth";
    changelog = "https://github.com/frostming/unearth/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ betaboon ];
    mainProgram = "unearth";
  };
}
