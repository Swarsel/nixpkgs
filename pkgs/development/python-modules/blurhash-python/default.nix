{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  pillow,
  pytestCheckHook,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "blurhash-python";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "woltapp";
    repo = "blurhash-python";
    rev = "v${version}";
    hash = "sha256-Cz+PkPp1knvT3U5ofyb1PstM9kzBOkgPbx03LgOLXgw=";
  };

  nativeBuildInputs = [
    cffi
    setuptools-scm
  ];

  propagatedBuildInputs = [
    cffi
    pillow
    six
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "blurhash" ];

  meta = {
    description = "Compact representation of a placeholder for an image";
    homepage = "https://github.com/woltapp/blurhash-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
