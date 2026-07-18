{
  lib,
  fetchFromGitHub,
  aiodns,
  buildPythonPackage,
  cached-ipaddress,
  ifaddr,
  libredirect,
  netifaces,
  poetry-core,
  pyroute2,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiodiscover";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiodiscover";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yrXy665O9VZ3aWn23QQCJm5USBV0P5aTSsQU5QGIcP8=";
  };

  nativeCheckInputs = [
    libredirect.hook
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  preCheck = ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/resolv.conf=$(realpath resolv.conf)
  '';

  build-system = [ poetry-core ];

  dependencies = [
    aiodns
    cached-ipaddress
    ifaddr
    netifaces
    pyroute2
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiodiscover" ];
  pythonRelaxDeps = [ "aiodns" ];

  meta = {
    description = "Python module to discover hosts via ARP and PTR lookup";
    homepage = "https://github.com/bdraco/aiodiscover";
    changelog = "https://github.com/bdraco/aiodiscover/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
