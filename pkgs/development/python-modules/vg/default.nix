{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "vg";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "lace";
    repo = "vg";
    tag = version;
    hash = "sha256-ZNUAfkhjmsxD8cH0fR8Htjs+/F/3R9xfe1XgRyndids=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'requires = ["setuptools", "poetry-core>=1.0.0"]' 'requires = ["poetry-core>=1.0.0"]'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ numpy ];
  disabledTests = [ "test_basic" ];
  pyproject = true;
  pythonImportsCheck = [ "vg" ];

  meta = {
    description = "Linear algebra for humans: a very good vector-geometry and linear-algebra toolbelt";
    homepage = "https://github.com/lace/vg";
    changelog = "https://github.com/lace/vg/blob/${version}/CHANGELOG.md";
    license = [ lib.licenses.bsd2 ];
    maintainers = with lib.maintainers; [ clerie ];
  };
}
