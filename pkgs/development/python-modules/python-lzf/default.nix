{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-lzf";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "teepark";
    repo = "python-lzf";
    tag = "release-${version}";
    hash = "sha256-n5E75kRqe0dDbyFicoyLBAVi/SuoUU7qJka3viipQk8=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Liblzf python bindings";
    homepage = "https://github.com/teepark/python-lzf";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
