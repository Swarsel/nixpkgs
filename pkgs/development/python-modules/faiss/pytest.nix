{
  lib,
  buildPythonPackage,
  faiss,
  faiss-build,
  pytestCheckHook,
  scipy,
}:

assert faiss.pythonSupport;

buildPythonPackage {
  inherit (faiss) version;
  pname = "faiss-pytest-suite";
  src = "${faiss-build.src}/tests";

  nativeCheckInputs = [
    faiss
    pytestCheckHook
    scipy
  ];

  # Tests that need GPUs and would fail in the sandbox
  disabledTestPaths = lib.optionals faiss.cudaSupport [ "test_contrib.py" ];

  disabledTests = [
    # https://github.com/facebookresearch/faiss/issues/2836
    "test_update_codebooks_with_double"
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;

  meta = faiss.meta // {
    description = "Faiss test suite";
  };
}
