{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nbmerge";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "jbn";
    repo = "nbmerge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uqs/SO/AculHCFYcbjW08kLQX5GSU/eAwkN2iy/vhLM=";
  };

  patches = [ ./pytest-compatibility.patch ];
  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  postCheck = ''
    patchShebangs .
    PATH=$PATH:$out/bin ./cli_tests.sh
  '';

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.nbformat ];
  pyproject = true;
  pythonImportsCheck = [ "nbmerge" ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Tool to merge/concatenate Jupyter (IPython) notebooks";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "nbmerge";
  };
})
