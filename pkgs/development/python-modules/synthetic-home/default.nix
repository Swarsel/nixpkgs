{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  python-slugify,
  pyyaml,
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "synthetic-home";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "synthetic-home";
    tag = finalAttrs.version;
    hash = "sha256-oXZVnw4Oc0jC1TBVTV4EI3Ta1zsqLop+c8uyEzAFpLI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    python-slugify
    pyyaml
    syrupy
  ];

  preCheck = ''
    export PATH="$PATH:$out/bin";
  '';

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "synthetic_home" ];

  meta = {
    description = "Library for managing synthetic home device registry";
    homepage = "https://github.com/allenporter/synthetic-home";
    changelog = "https://github.com/allenporter/synthetic-home/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
