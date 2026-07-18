{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  poetry-core,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nats-python";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "Gr1N";
    repo = "nats-python";
    tag = version;
    hash = "sha256-7/AGQfPEuSeoRGUXeyDZNbLhapfQa7vhrSPHRruf+sg=";
  };

  patches = [
    # Switch to poetry-core, https://github.com/Gr1N/nats-python/pull/19
    (fetchpatch {
      hash = "sha256-9AUd/anWCAhuD0VdxRm6Ydlst8nttjwfPmqK+S8ON7o=";
      name = "use-poetry-core.patch";
      url = "https://github.com/Gr1N/nats-python/commit/71b25b324212dccd7fc06ba3914491adba22e83f.patch";
    })
  ];

  # Tests require a running NATS server
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pynats" ];

  meta = {
    description = "Python client for NATS messaging system";
    homepage = "https://github.com/Gr1N/nats-python";
    changelog = "https://github.com/Gr1N/nats-python/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
