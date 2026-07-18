{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "diskcache-stubs";
  version = "5.6.3.6";

  src = fetchFromGitHub {
    owner = "phi-friday";
    repo = "diskcache-stubs";
    tag = "v${version}";
    hash = "sha256-yYds/00K9XyJirreBGG/r30HZTyBQbFa6N4EizsmdKg=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "diskcache-stubs" ];

  meta = {
    description = "Diskcache stubs";
    homepage = "https://github.com/phi-friday/diskcache-stubs";
    changelog = "https://github.com/phi-friday/diskcache-stubs/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
