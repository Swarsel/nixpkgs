{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aiointercept,
  buildPythonPackage,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "aioimmich";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "mib1185";
    repo = "aioimmich";
    tag = "v${version}";
    hash = "sha256-/Y4wSiaXpQXn0V+g56rL62fdE7SWl9L4sBeEL3nkGD8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail setuptools==82.0.1 setuptools
  '';

  nativeCheckInputs = [
    aiointercept
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioimmich" ];

  meta = {
    description = "Asynchronous library to fetch albums and assests from immich";
    homepage = "https://github.com/mib1185/aioimmich";
    changelog = "https://github.com/mib1185/aioimmich/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
