{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "diff-match-patch";
  version = "20241021";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vq5XqZ+kgIRTKTXuKWi4Zh24YYYuyCxvIfSs3W2DUHM=";
    pname = "diff_match_patch";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  dependencies = [ flit-core ];
  pyproject = true;

  meta = {
    description = "Diff, Match and Patch libraries for Plain Text";
    homepage = "https://github.com/diff-match-patch-python/diff-match-patch";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
