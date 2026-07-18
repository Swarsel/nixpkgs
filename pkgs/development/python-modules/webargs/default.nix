{
  lib,
  aiohttp,
  bottle,
  buildPythonPackage,
  django,
  falcon,
  fetchPypi,
  flask,
  flit-core,
  marshmallow,
  pyramid,
  pytest-aiohttp,
  pytestCheckHook,
  tornado,
  webtest,
  webtest-aiohttp,
}:

buildPythonPackage rec {
  pname = "webargs";
  version = "8.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eZv5A5x2wj/Y3BlREHp1qeVhIDwV1q6PicHkbiNGNsE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
    webtest
    webtest-aiohttp
    flask
    django
    bottle
    tornado
    pyramid
    falcon
    aiohttp
  ];

  build-system = [ flit-core ];
  dependencies = [ marshmallow ];
  pyproject = true;
  pythonImportsCheck = [ "webargs" ];

  meta = {
    description = "Declarative parsing and validation of HTTP request objects, with built-in support for popular web frameworks";
    homepage = "https://github.com/marshmallow-code/webargs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cript0nauta ];
  };
}
