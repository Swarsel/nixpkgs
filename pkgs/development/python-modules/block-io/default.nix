{
  lib,
  base58,
  bitcoin-utils-fork-minimal,
  buildPythonPackage,
  fetchPypi,
  pycryptodome,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "block-io";
  version = "2.0.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-M7czfpagXqoWWSu4enB3Z2hc2GtAaskI6cnJzJdpC8I=";
  };

  # Tests needs a BlockIO API key to run properly
  # https://github.com/BlockIo/block_io-python/blob/79006bc8974544b70a2d8e9f19c759941d32648e/test.py#L18
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    base58
    bitcoin-utils-fork-minimal
    pycryptodome
    requests
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "block_io" ];
  pythonRelaxDeps = [ "base58" ];

  meta = {
    description = "Integrate Bitcoin, Dogecoin and Litecoin in your Python applications using block.io";
    homepage = "https://github.com/BlockIo/block_io-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
