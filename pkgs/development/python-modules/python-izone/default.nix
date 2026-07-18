{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  netifaces,
  pytest-aio,
  pytest-asyncio,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "python-izone";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "Swamp-Ig";
    repo = "pizone";
    tag = "v${version}";
    hash = "sha256-/wErnm3SY5N/Bm1oODQsAVTPAtERcrJqwPt1ipDBuZ0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools_scm_git_archive",' ""
  '';

  doCheck = false; # most tests access network

  nativeCheckInputs = [
    pytest-aio
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    netifaces
  ];

  pyproject = true;
  pythonImportsCheck = [ "pizone" ];

  meta = {
    description = "Python interface to the iZone airconditioner controller";
    homepage = "https://github.com/Swamp-Ig/pizone";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
