{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libgphoto2,
  pkg-config,
  pytestCheckHook,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "gphoto2";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "jim-easterbrook";
    repo = "python-gphoto2";
    tag = "v${version}";
    hash = "sha256-fxrgHFVfTs7PZFHafld5uNmvaqW2uLAs01GatdxtbAU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ libgphoto2 ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "gphoto2" ];

  meta = {
    description = "Python interface to libgphoto2";
    homepage = "https://github.com/jim-easterbrook/python-gphoto2";
    changelog = "https://github.com/jim-easterbrook/python-gphoto2/blob/${src.tag}/CHANGELOG.txt";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
