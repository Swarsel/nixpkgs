{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiocontextvars";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "fantix";
    repo = "aiocontextvars";
    rev = "v${version}";
    hash = "sha256-s1YhpBLz+YNmUO+0BOltfjr3nz4m6mERszNqlmquTyg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'," ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Asyncio support for PEP-567 contextvars backport";
    homepage = "https://github.com/fantix/aiocontextvars";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
