{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiohttp-wsgi";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "etianen";
    repo = "aiohttp-wsgi";
    rev = "v${version}";
    hash = "sha256-3Q00FidZWV1KueuHyHKQf1PsDJGOaRW6v/kBy7lzD4Q=";
  };

  propagatedBuildInputs = [ aiohttp ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "aiohttp_wsgi" ];

  meta = {
    description = "WSGI adapter for aiohttp";
    homepage = "https://github.com/etianen/aiohttp-wsgi";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aiohttp-wsgi-serve";
  };
}
