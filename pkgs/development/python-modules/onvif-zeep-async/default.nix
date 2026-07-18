{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  ciso8601,
  setuptools,
  yarl,
  zeep,
}:

buildPythonPackage (finalAttrs: {
  pname = "onvif-zeep-async";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "openvideolibs";
    repo = "python-onvif-zeep-async";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7o9rzpXLNX5Ibaj74bNbFZ6v55SMDyzYjutvimOxbYk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=82.0.1" setuptools
  '';

  # Tests are not shipped
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    ciso8601
    yarl
    zeep
  ]
  ++ zeep.optional-dependencies.async;

  pyproject = true;
  pythonImportsCheck = [ "onvif" ];

  meta = {
    description = "ONVIF Client Implementation in Python";
    homepage = "https://github.com/hunterjm/python-onvif-zeep-async";
    changelog = "https://github.com/openvideolibs/python-onvif-zeep-async/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "onvif-cli";
  };
})
