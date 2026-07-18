{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  sniffio,
}:

buildPythonPackage rec {
  pname = "asgi-lifespan";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "florimondmanca";
    repo = "asgi-lifespan";
    tag = version;
    hash = "sha256-Jgmd/4c1lxHM/qi3MJNN1aSSUJrI7CRNwwHrFwwcCkc=";
  };

  postPatch = ''
    sed -i "/--cov/d" setup.cfg
  '';

  # Circular dependencies, starlette
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ sniffio ];
  pyproject = true;
  pythonImportsCheck = [ "asgi_lifespan" ];

  meta = {
    description = "Programmatic startup/shutdown of ASGI apps";
    homepage = "https://github.com/florimondmanca/asgi-lifespan";
    changelog = "https://github.com/florimondmanca/asgi-lifespan/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
