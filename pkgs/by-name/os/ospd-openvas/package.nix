{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ospd-openvas";
  version = "22.10.1";

  src = fetchFromGitHub {
    owner = "greenbone";
    repo = "ospd-openvas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YrCYudM45xDSQRNhUfYAxFNKToMsWdGwtDYJiZ0E6+c=";
  };

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    defusedxml
    deprecated
    lxml
    packaging
    paho-mqtt
    psutil
    python-gnupg
    redis
    sentry-sdk
  ];

  pyproject = true;
  pythonImportsCheck = [ "ospd_openvas" ];

  pythonRelaxDeps = [
    "defusedxml"
    "lxml"
    "packaging"
    "psutil"
    "python-gnupg"
  ];

  meta = {
    description = "OSP server implementation to allow GVM to remotely control an OpenVAS Scanner";
    homepage = "https://github.com/greenbone/ospd-openvas";
    changelog = "https://github.com/greenbone/ospd-openvas/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
  };
})
