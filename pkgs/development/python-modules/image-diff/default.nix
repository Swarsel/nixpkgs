{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  click-default-group,
  pillow,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "image-diff";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "image-diff";
    rev = version;
    hash = "sha256-AQykJNvBgVjmPVTwJOX17eKWelqvZZieq/giid8GYAY=";
  };

  propagatedBuildInputs = [
    pillow
    click
    click-default-group
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "image_diff" ];

  meta = {
    description = "CLI tool for comparing images";
    homepage = "https://github.com/simonw/image-diff";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "image-diff";
  };
}
