{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  xeger,
}:

buildPythonPackage rec {
  pname = "raspyrfm-client";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "markusressel";
    repo = "raspyrfm-client";
    tag = version;
    hash = "sha256-+TraMrVoR8GXrjfjJnu1uyyW6KTnu8KrRqAHYU8thFw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    xeger
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "raspyrfm_client" ];

  meta = {
    description = "Send rc signals with the RaspyRFM module";
    homepage = "https://github.com/markusressel/raspyrfm-client";
    changelog = "https://github.com/markusressel/raspyrfm-client/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
