{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  ciso8601,
  kasa-crypt,
  orjson,
  requests,
  setuptools,
  websocket-client,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "sense-energy";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "scottbonline";
    repo = "sense";
    tag = finalAttrs.version;
    hash = "sha256-QFwESlynFXV/OqD9LfPeUdIsWgK7R6XZqhSchmHUtSw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "{{VERSION_PLACEHOLDER}}" "${finalAttrs.version}"
  '';

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    kasa-crypt
    orjson
    ciso8601
    requests
    websocket-client
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "sense_energy" ];

  meta = {
    description = "API for the Sense Energy Monitor";
    homepage = "https://github.com/scottbonline/sense";
    changelog = "https://github.com/scottbonline/sense/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
