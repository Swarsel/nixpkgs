{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  av,
  buildPythonPackage,
  mashumaro,
  # meta
  music-assistant,
  nixosTests,
  numpy,
  orjson,
  pillow,
  pyprojectVersionPatchHook,
  # test dependencies
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  # build-system
  setuptools,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiosendspin";
  version = "6.0.5";

  src = fetchFromGitHub {
    owner = "Sendspin";
    repo = "aiosendspin";
    tag = finalAttrs.version;
    hash = "sha256-veX6MZSqEQb+tEqZTEgdCObLdaVPJEdTFW5Ivmb0TNQ=";
  };

  postPatch = ''
    # too narrow timeouts, so remove pytest-timeout
    sed -i "/addopts/d" pyproject.toml
  '';

  nativeBuildInputs = [
    # https://github.com/Sendspin/aiosendspin/blob/5.3.0/pyproject.toml#L27
    pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.server;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    zeroconf
  ];

  optional-dependencies = {
    server = [
      av
      numpy
      pillow
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "aiosendspin"
  ];

  passthru = {
    # needs manual compat testing with music-assistant (sendspin provider)
    skipBulkUpdate = true; # nixpkgs-update: no auto update
    tests = nixosTests.music-assistant;
  };

  meta = {
    inherit (music-assistant.meta) maintainers;
    description = "Async Python library implementing the Sendspin Protocol";
    homepage = "https://github.com/Sendspin/aiosendspin";
    changelog = "https://github.com/Sendspin/aiosendspin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
  };
})
