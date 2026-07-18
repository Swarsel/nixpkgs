{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  psutil,
  pyasynchat,
  pyasyncore,
  pyopenssl,
  pysendfile,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyftpdlib";
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-S6BkIHh5LfY907LpyPg48qPs9CjHUY1ZIcBTDVNRKs8=";
  };

  # Impure filesystem-related tests cause timeouts
  # on Hydra: https://hydra.nixos.org/build/84374861
  doCheck = false;

  nativeCheckInputs = [
    mock
    psutil
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyasyncore
    pyasynchat
    pysendfile
  ];

  optional-dependencies = {
    ssl = [ pyopenssl ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyftpdlib" ];

  meta = {
    description = "Asynchronous FTP server library";
    homepage = "https://github.com/giampaolo/pyftpdlib/";
    changelog = "https://github.com/giampaolo/pyftpdlib/blob/release-${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "ftpbench";
  };
}
