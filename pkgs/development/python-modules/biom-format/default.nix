{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  # build-system
  cython,
  h5py,
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "biom-format";
  version = "2.1.17";

  src = fetchFromGitHub {
    owner = "biocore";
    repo = "biom-format";
    tag = finalAttrs.version;
    hash = "sha256-FjIC21LoqltixBstbbANByjTNxVm/3YCxdWaD9KbOQ0=";
  };

  # https://numpy.org/doc/stable//release/2.4.0-notes.html#removed-numpy-in1d
  postPatch = ''
    substituteInPlace biom/table.py \
      --replace-fail "np.in1d" "np.isin"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  # make pytest resolve the package from $out
  # some tests don't work if we change the level of directory nesting
  preCheck = ''
    mkdir biom_tests
    mv biom/tests biom_tests/tests
    rm -r biom
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    click
    h5py
    numpy
    pandas
    scipy
  ];

  enabledTestPaths = [ "biom_tests/tests" ];
  pyproject = true;
  pythonImportsCheck = [ "biom" ];

  meta = {
    description = "Biological Observation Matrix (BIOM) format";
    homepage = "http://biom-format.org/";
    changelog = "https://github.com/biocore/biom-format/blob/${finalAttrs.src.tag}/ChangeLog.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tomasajt ];
    downloadPage = "https://github.com/biocore/biom-format";
  };
})
