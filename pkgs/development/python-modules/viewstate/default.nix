{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "viewstate";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "yuvadm";
    repo = "viewstate";
    tag = "v${version}";
    sha256 = "sha256-fvqz03rKkA2WVVXU74eo0otnuRseE83cv6pw3rMso34=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = ".NET viewstate decoder";
    homepage = "https://github.com/yuvadm/viewstate";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
}
