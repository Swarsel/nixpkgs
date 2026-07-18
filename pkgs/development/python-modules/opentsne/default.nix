{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  pytestCheckHook,
  scikit-learn,
  scipy,
  setuptools,
}:

let
  self = buildPythonPackage rec {
    pname = "opentsne";
    version = "1.0.4";

    src = fetchFromGitHub {
      owner = "pavlin-policar";
      repo = "openTSNE";
      tag = "v${version}";
      hash = "sha256-cGnhdGpDiBlTeeveCtnveslDytpNO8vtYkxQQ7FhsuA=";
    };

    doCheck = false;

    build-system = [
      cython
      numpy
      setuptools
    ];

    dependencies = [
      numpy
      scipy
      scikit-learn
    ];

    pyproject = true;
    pythonImportsCheck = [ "openTSNE" ];

    passthru = {
      tests.pytest = self.overridePythonAttrs (old: {
        pname = "${old.pname}-tests";
        postPatch = "rm openTSNE -rf";
        doCheck = true;

        nativeCheckInputs = [
          pytestCheckHook
          self
        ];

        doBuild = false;
        doInstall = false;
        pyproject = false;
      });
    };

    meta = {
      description = "Modular Python implementation of t-Distributed Stochasitc Neighbor Embedding";
      homepage = "https://github.com/pavlin-policar/openTSNE";
      changelog = "https://github.com/pavlin-policar/openTSNE/releases/tag/v${version}";
      license = lib.licenses.bsd3;
      maintainers = [ ];
    };
  };
in
self
