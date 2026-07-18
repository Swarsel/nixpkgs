{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-split-settings";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "wemake-services";
    repo = "django-split-settings";
    rev = version;
    hash = "sha256-Bk2/DU+K524mCUvteWT0fIQH5ZgeMHiufMTF+dJYVtc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry.masonry" "poetry.core.masonry"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "split_settings" ];

  meta = {
    description = "Organize Django settings into multiple files and directories";
    homepage = "https://github.com/wemake-services/django-split-settings";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
