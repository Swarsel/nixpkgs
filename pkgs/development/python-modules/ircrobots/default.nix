{
  lib,
  fetchFromGitHub,
  anyio,
  async-stagger,
  async-timeout,
  asyncio-rlock,
  asyncio-throttle,
  buildPythonPackage,
  ircstates,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "ircrobots";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "jesopo";
    repo = "ircrobots";
    rev = "v${version}";
    hash = "sha256-slz4AH2Mi21N3aV+OrnoXoQsseS7arW2NuUZARQJsf0=";
  };

  propagatedBuildInputs = [
    anyio
    asyncio-rlock
    asyncio-throttle
    ircstates
    async-stagger
    async-timeout
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ircrobots" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Asynchronous bare-bones IRC bot framework for python3";
    homepage = "https://github.com/jesopo/ircrobots";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
