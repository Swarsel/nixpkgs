{
  lib,
  buildPythonPackage,
  decopatch,
  fetchPypi,
  flit-core,
  more-itertools,
  nestedtext,
  numpy,
  pytestCheckHook,
  pyyaml,
  tidyexc,
  toml,
}:

buildPythonPackage rec {
  pname = "parametrize-from-file";
  version = "0.21.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-keKsnkMyk9du7TGvJhZXP2EpLqOKkz8vxrRzWXyGg0U=";
    pname = "parametrize_from_file";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    decopatch
    more-itertools
    nestedtext
    pyyaml
    tidyexc
    toml
  ];

  # patch out coveralls since it doesn't provide us value
  preBuild = ''
    sed -i '/coveralls/d' ./pyproject.toml

    substituteInPlace pyproject.toml \
      --replace "more_itertools~=8.10" "more_itertools"
  '';

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  disabledTests = [
    # https://github.com/kalekundert/parametrize_from_file/issues/19
    "test_load_suite_params_err"
  ];

  pyproject = true;
  pythonImportsCheck = [ "parametrize_from_file" ];

  meta = {
    description = "Read unit test parameters from config files";
    homepage = "https://github.com/kalekundert/parametrize_from_file";
    changelog = "https://github.com/kalekundert/parametrize_from_file/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
