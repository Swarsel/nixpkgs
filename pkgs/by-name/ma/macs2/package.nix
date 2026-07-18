{
  lib,
  fetchPypi,
  fetchpatch,
  python311,
}:

# pin python311 because macs2 does not support python 3.12
# https://github.com/macs3-project/MACS/issues/598#issuecomment-1812622572
python311.pkgs.buildPythonPackage rec {
  pname = "macs2";
  version = "2.2.9.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jVa8N/uCP8Y4fXgTjOloQFxUoKjNl3ZoJwX9CYMlLRY=";
    pname = lib.toUpper pname;
  };

  patches = [
    # https://github.com/macs3-project/MACS/pull/590
    (fetchpatch {
      hash = "sha256-WB3Ubqk5fKtZt97QYo/sZDU/yya9MUo1NL4VsKXR+Yo=";
      name = "remove-pip-build-dependency.patch";
      url = "https://github.com/macs3-project/MACS/commit/cf95a930daccf9f16e5b9a9224c5a2670cf67939.patch";
    })
  ];

  nativeCheckInputs = with python311.pkgs; [
    unittestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = with python311.pkgs; [
    cython_0
    numpy
    setuptools
  ];

  dependencies = with python311.pkgs; [
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "MACS2" ];

  unittestFlagsArray = [
    "-s"
    "test"
  ];

  meta = {
    description = "Model-based Analysis for ChIP-Seq";
    homepage = "https://github.com/macs3-project/MACS/";
    changelog = "https://github.com/macs3-project/MACS/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "macs2";
  };
}
