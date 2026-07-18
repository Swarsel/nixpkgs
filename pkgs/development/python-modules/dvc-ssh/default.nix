{
  lib,
  bcrypt,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  setuptools,
  setuptools-scm,
  sshfs,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-ssh";
  version = "4.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-NgfzEZW5WmDaP85apROMvITy545CHse9z94xC/Jw9OA=";
    pname = "dvc_ssh";
  };

  # bcrypt is enabled for sshfs in nixpkgs
  postPatch = ''
    substituteInPlace setup.cfg --replace "sshfs[bcrypt]" "sshfs"
  '';

  # Network access is needed for tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    bcrypt
    dvc-objects
    sshfs
  ];

  optional-dependencies = {
    gssapi = [ sshfs ];
  };

  pyproject = true;

  pythonRemoveDeps = [
    # Prevent circular dependency
    "dvc"
  ];

  # Circular dependency
  # pythonImportsCheck = [
  #  "dvc_ssh"
  # ];
  meta = {
    description = "SSH plugin for dvc";
    homepage = "https://pypi.org/project/dvc-ssh/";
    changelog = "https://github.com/iterative/dvc-ssh/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
