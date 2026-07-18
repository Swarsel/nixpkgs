{
  lib,
  fetchFromGitHub,
  base58,
  blake3,
  buildPythonPackage,
  mmh3,
  morphys,
  pytestCheckHook,
  setuptools,
  six,
  varint,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-multihash";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "multiformats";
    repo = "py-multihash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hdjJJh77P4dJQAIGTlPGolz1qDumvNOaIMyfxmWMzUk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    base58
    blake3
    morphys
    mmh3
    six
    varint
  ];

  pyproject = true;
  pythonImportsCheck = [ "multihash" ];

  meta = {
    description = "Self describing hashes - for future proofing";
    homepage = "https://github.com/multiformats/py-multihash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rakesh4g ];
  };
})
