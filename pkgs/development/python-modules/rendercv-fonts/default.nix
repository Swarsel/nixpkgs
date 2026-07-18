{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rendercv-fonts";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "rendercv";
    repo = "rendercv-fonts";
    tag = "v${version}";
    hash = "sha256-rwMiDoa/93FY3DFDxzR3sPyB8tCJzOnNbMZq8mBcx7M=";
  };

  # pythonRelaxDeps seems not taking effect for the build-system dependencies
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'hatchling==1.26.3' 'hatchling'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "rendercv_fonts" ];

  meta = {
    description = "Python package with some fonts for the rendercv package";
    homepage = "https://github.com/rendercv/rendercv-fonts";
    changelog = "https://github.com/rendercv/rendercv-fonts/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ theobori ];
  };
}
