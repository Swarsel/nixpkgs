{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cronsim";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "cuu508";
    repo = "cronsim";
    tag = finalAttrs.version;
    hash = "sha256-9TextQcZAX5Ri6cc+Qd4T+u8XjxriqoTsy/9/G8XDAM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cronsim" ];

  meta = {
    description = "Cron expression parser and evaluator";
    homepage = "https://github.com/cuu508/cronsim";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ phaer ];
  };
})
