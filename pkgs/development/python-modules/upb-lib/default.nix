{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  pytz,
  serialx,
}:

buildPythonPackage (finalAttrs: {
  pname = "upb-lib";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "gwww";
    repo = "upb-lib";
    tag = finalAttrs.version;
    hash = "sha256-J7jE/r+NkuzZxI4EnECH0HSnje2RqkZanEL8L5rUP1k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    pytz
    serialx
  ];

  pyproject = true;
  pythonImportsCheck = [ "upb_lib" ];

  meta = {
    description = "Library for interacting with UPB PIM";
    homepage = "https://github.com/gwww/upb-lib";
    changelog = "https://github.com/gwww/upb-lib/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
