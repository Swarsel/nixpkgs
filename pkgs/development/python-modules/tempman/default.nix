{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tempman";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "python-tempman";
    tag = version;
    hash = "sha256-EHTnlT3vcmyjyyS3QCJXjAuZqOEc0i11rEb6zfX6rDY=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'read("README")' '""'
  '';

  # Disabling tests, they rely on dependencies that are outdated and not supported
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "tempman" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Create and clean up temporary directories";
    homepage = "https://github.com/mwilliamson/python-tempman";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
