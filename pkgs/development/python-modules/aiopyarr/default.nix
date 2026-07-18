{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  ciso8601,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiopyarr";
  version = "23.4.0";

  src = fetchFromGitHub {
    owner = "tkdrob";
    repo = "aiopyarr";
    tag = finalAttrs.version;
    hash = "sha256-CzNB6ymvDTktiOGdcdCvWLVQ3mKmbdMpc/vezSXCpG4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'version="master"' 'version="${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    ciso8601
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiopyarr" ];

  meta = {
    description = "Python API client for Lidarr/Radarr/Readarr/Sonarr";
    homepage = "https://github.com/tkdrob/aiopyarr";
    changelog = "https://github.com/tkdrob/aiopyarr/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
