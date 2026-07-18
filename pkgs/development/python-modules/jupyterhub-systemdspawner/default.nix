{
  lib,
  fetchFromGitHub,
  bash,
  buildPythonPackage,
  jupyterhub,
  setuptools,
  tornado,
}:

buildPythonPackage rec {
  pname = "jupyterhub-systemdspawner";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "jupyterhub";
    repo = "systemdspawner";
    tag = "v${version}";
    hash = "sha256-obM8HGCHsisRV1+kHMWdA7d6eb6awwPMBuDUAf3k0uI=";
  };

  postPatch = ''
    substituteInPlace systemdspawner/systemdspawner.py \
      --replace-fail "/bin/bash" "${bash}/bin/bash"
  '';

  # Module has no tests
  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin
    cp check-kernel.bash $out/bin/
    patchShebangs $out/bin
  '';

  build-system = [ setuptools ];

  dependencies = [
    jupyterhub
    tornado
  ];

  pyproject = true;
  pythonImportsCheck = [ "systemdspawner" ];

  meta = {
    description = "JupyterHub Spawner using systemd for resource isolation";
    homepage = "https://github.com/jupyterhub/systemdspawner";
    changelog = "https://github.com/jupyterhub/systemdspawner/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "check-kernel.bash";
  };
}
