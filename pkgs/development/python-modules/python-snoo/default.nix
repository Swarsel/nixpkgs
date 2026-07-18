{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiomqtt,
  buildPythonPackage,
  freenub,
  mashumaro,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "python-snoo";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "Lash-L";
    repo = "python-snoo";
    tag = "v${version}";
    hash = "sha256-IbBNdtRZdXrN6dyR0cdKsrx3kxxBTUmfAxmuJy4p5x4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail poetry-core==1.8.0 poetry-core
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aiomqtt
    freenub
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_snoo" ];

  meta = {
    description = "Control Snoo devices via python and get auto updates";
    homepage = "https://github.com/Lash-L/python-snoo";
    changelog = "https://github.com/Lash-L/python-snoo/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
