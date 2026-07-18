{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  pycryptodome,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-secrets";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "Onemind-Services-LLC";
    repo = "netbox-secrets";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4qUbzQTfSCXT7b8DfrsP9y3tatJZa5F40kl9tuMKed4=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pycryptodome ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_secrets" ];

  meta = {
    description = "NetBox plugin to enhance secret management with encrypted storage and flexible, user-friendly features";
    homepage = "https://github.com/Onemind-Services-LLC/netbox-secrets";
    changelog = "https://github.com/Onemind-Services-LLC/netbox-secrets/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
