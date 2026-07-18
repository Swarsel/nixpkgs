{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django-polymorphic,
  netbox,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-lifecycle";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "DanSheps";
    repo = "netbox-lifecycle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iCBlwhaf6IFdni7FQyRPtRJVwt04w0Jc4R0CeQlIWCY=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ django-polymorphic ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_lifecycle" ];

  meta = {
    description = "NetBox plugin for managing Hardware EOL/EOS, and Support Contracts";
    homepage = "https://github.com/DanSheps/netbox-lifecycle";
    changelog = "https://github.com/DanSheps/netbox-lifecycle/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
