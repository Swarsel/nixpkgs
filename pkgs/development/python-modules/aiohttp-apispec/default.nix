{
  lib,
  fetchFromGitHub,
  aiohttp,
  apispec,
  buildPythonPackage,
  jinja2,
  packaging,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
  webargs,
}:

buildPythonPackage rec {
  pname = "aiohttp-apispec";
  version = "3.0.0b2";

  src = fetchFromGitHub {
    owner = "maximdanilchenko";
    repo = "aiohttp-apispec";
    tag = "v${version}";
    hash = "sha256-C+/M25oCLTNGGEUj2EyXn3UjcvPvDYFmmUW8IOoF1uU=";
  };

  doCheck = false;

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  /*
    postPatch = ''
      substituteInPlace tests/conftest.py \
        --replace-fail 'aiohttp_app(loop,' 'aiohttp_app(event_loop,' \
        --replace-fail 'return loop.run_until_complete' 'return event_loop.run_until_complete'
    '';
  */
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    apispec
    jinja2
    packaging
    webargs
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_apispec" ];

  meta = {
    description = "Build and document REST APIs with aiohttp and apispec";
    homepage = "https://github.com/maximdanilchenko/aiohttp-apispec/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
