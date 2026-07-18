{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  ipdb,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "drf-nested-routers";
  version = "0.95.0";

  src = fetchFromGitHub {
    owner = "alanjds";
    repo = "drf-nested-routers";
    tag = "v${version}";
    hash = "sha256-9oB6pmhZJVvVJeueY44q9ST1JgjmK1FF8QMx7mX5ZFI=";
  };

  buildInputs = [ django ];
  propagatedBuildInputs = [ djangorestframework ];

  nativeCheckInputs = [
    ipdb
    pytestCheckHook
    pytest-django
  ];

  format = "setuptools";

  meta = {
    description = "Provides routers and fields to create nested resources in the Django Rest Framework";
    homepage = "https://github.com/alanjds/drf-nested-routers";
    changelog = "https://github.com/alanjds/drf-nested-routers/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felschr ];
  };
}
