{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "more-itertools";
  version = "10.8.0";

  src = fetchFromGitHub {
    owner = "more-itertools";
    repo = "more-itertools";
    tag = "v${version}";
    hash = "sha256-ZKvucnPFCA6Q4EQn/nKC9LIevOdSYXHIJ3w3Frregic=";
  };

  propagatedBuildInputs = [ six ];
  # iterable = range(10 ** 10)  # Is efficiently reversible
  # OverflowError: Python int too large to convert to C long
  doCheck = !stdenv.hostPlatform.is32bit;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;

  meta = {
    description = "Expansion of the itertools module";
    homepage = "https://more-itertools.readthedocs.org";
    changelog = "https://more-itertools.readthedocs.io/en/stable/versions.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/more-itertools/more-itertools";
  };
}
