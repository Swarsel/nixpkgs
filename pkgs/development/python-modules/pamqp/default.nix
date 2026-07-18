{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pamqp";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "gmr";
    repo = "pamqp";
    tag = finalAttrs.version;
    hash = "sha256-WKkiwisCfGRkNbw8WtXqNe4OqUiRgVfVL7o0oMdeFJw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;

  pythonImportsCheck = [
    "pamqp.base"
    "pamqp.body"
    "pamqp.commands"
    "pamqp.common"
    "pamqp.decode"
    "pamqp.encode"
    "pamqp.exceptions"
    "pamqp.frame"
    "pamqp.header"
    "pamqp.heartbeat"
  ];

  meta = {
    description = "RabbitMQ Focused AMQP low-level library";
    homepage = "https://github.com/gmr/pamqp";
    changelog = "https://github.com/gmr/pamqp/blob/${finalAttrs.src.tag}/docs/changelog.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
