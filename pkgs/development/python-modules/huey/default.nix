{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  redis,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "huey";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "coleifer";
    repo = "huey";
    tag = finalAttrs.version;
    hash = "sha256-vXp8xISf8g1VjIus/Xr4wKFFaVg5x4CXgP8IUUKYl+o=";
  };

  # connects to redis
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ redis ];
  pyproject = true;
  pythonImportsCheck = [ "huey" ];

  meta = {
    description = "Module to queue tasks";
    homepage = "https://github.com/coleifer/huey";
    changelog = "https://github.com/coleifer/huey/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
