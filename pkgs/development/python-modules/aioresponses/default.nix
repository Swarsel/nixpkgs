{
  lib,
  # dependencies
  aiohttp,
  buildPythonPackage,
  # tests
  ddt,
  fetchPypi,
  # build-system
  pbr,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioresponses";
  version = "0.7.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uGHN/l3FjzuK+sewppc9XXsstgjdD2JT0WuO6Or23xE=";
  };

  patches = [
    # https://github.com/pnuckowski/aioresponses/issues/289
    # https://github.com/pnuckowski/aioresponses/pull/292
    ./aiohttp-3.14-compat.patch
  ];

  postPatch = ''
    # https://github.com/pnuckowski/aioresponses/pull/278
    substituteInPlace aioresponses/core.py \
      --replace-fail asyncio.iscoroutinefunction inspect.iscoroutinefunction
  '';

  nativeBuildInputs = [
    pbr
    setuptools
  ];

  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    ddt
    pytestCheckHook
  ];

  disabledTests = [
    # Skip tests which make requests to httpbin.org
    "test_address_as_instance_of_url_combined_with_pass_through"
    "test_pass_through_with_origin_params"
    "test_pass_through_unmatched_requests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioresponses" ];

  meta = {
    description = "Helper to mock/fake web requests in python aiohttp package";
    homepage = "https://github.com/pnuckowski/aioresponses";
    license = lib.licenses.mit;
  };
}
