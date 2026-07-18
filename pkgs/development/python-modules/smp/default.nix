{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cbor2,
  crcmod,
  eval-type-backport,
  poetry-core,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "smp";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "JPHutchins";
    repo = "smp";
    tag = version;
    hash = "sha256-RjecTnMYNcJeD7wqq4FkwRvEgTn5V/RwMfOjf2dqQ+U=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    cbor2
    crcmod
    eval-type-backport
    pydantic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "smp"
  ];

  meta = {
    description = "Simple Management Protocol (SMP) for remotely managing MCU firmware";
    homepage = "https://github.com/JPHutchins/smp";
    changelog = "https://github.com/JPHutchins/smp/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
  };
}
