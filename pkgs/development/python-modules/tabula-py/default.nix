{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distro,
  jpype1,
  jre,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "tabula-py";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "chezou";
    repo = "tabula-py";
    tag = "v${version}";
    hash = "sha256-PQbwm9ho3XtpmZ7N7ASkrV8gk9Jom+yQKlt2fUa948s=";
  };

  postPatch = ''
    substituteInPlace tabula/backend.py \
      --replace-fail '"java"' '"${lib.getExe jre}"'
  '';

  buildInputs = [ jre ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    distro
    numpy
    pandas
    jpype1
  ];

  disabledTests = [
    # Tests require network access
    "test_convert_remote_file"
    "test_read_pdf_with_remote_template"
    "test_read_remote_pdf"
    "test_read_remote_pdf_with_custom_user_agent"
    # not sure what it checks
    # probably related to jpype, but we use subprocess instead
    # https://github.com/chezou/tabula-py/issues/352#issuecomment-1730791540
    # Failed: DID NOT RAISE <class 'RuntimeError'>
    "test_read_pdf_with_silent_true"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tabula" ];

  meta = {
    description = "Module to extract table from PDF into pandas DataFrame";
    homepage = "https://github.com/chezou/tabula-py";
    changelog = "https://github.com/chezou/tabula-py/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
