{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  lxml,
  paramiko,
  poetry-core,
  pontos,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-gvm";
  version = "26.11.1";

  src = fetchFromGitHub {
    owner = "greenbone";
    repo = "python-gvm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NTUDFZnDavHhl5AELMNj8AkwwVtY+96cMB9uhm4veQg=";
  };

  nativeCheckInputs = [
    pontos
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    defusedxml
    lxml
    paramiko
    typing-extensions
  ];

  disabledTests = [
    # No running SSH available
    "test_connect_error"
    "test_feed_xml_error"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_feed_xml_error" ];

  pyproject = true;
  pythonImportsCheck = [ "gvm" ];
  pythonRelaxDeps = [ "defusedxml" ];

  meta = {
    description = "Collection of APIs that help with remote controlling a Greenbone Security Manager";
    homepage = "https://github.com/greenbone/python-gvm";
    changelog = "https://github.com/greenbone/python-gvm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
