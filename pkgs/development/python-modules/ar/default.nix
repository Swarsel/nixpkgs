{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ar";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "vidstige";
    repo = "ar";
    tag = "v${version}";
    hash = "sha256-uaEkp2uCiRMj8pTBgA6NESJO3Eh5pVc+FfX/enIBcNA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  dependencies = [
    hatch-vcs
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_list"
    "test_read_content"
    "test_read_binary"
    "test_read_content_ext"
    "test_read_binary_ext"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ar" ];

  meta = {
    description = "Implementation of the ar archive format";
    homepage = "https://github.com/vidstige/ar";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
