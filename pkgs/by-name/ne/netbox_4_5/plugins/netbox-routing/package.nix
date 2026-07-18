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
  pname = "netbox-routing";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "DanSheps";
    repo = "netbox-routing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3biANhaAi3uRtaXnAw4i6nWnHkARkkBVqyBHLXIMOdA=";
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
  pythonImportsCheck = [ "netbox_routing" ];

  meta = {
    description = "NetBox plugin for tracking all kinds of routing information";
    homepage = "https://github.com/DanSheps/netbox-routing";
    changelog = "https://github.com/DanSheps/netbox-routing/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ benley ];
  };
})
