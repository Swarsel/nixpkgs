{
  lib,
  fetchFromGitHub,
  bashInteractive,
  buildPythonPackage,
  filetype,
  flit-core,
  ipykernel,
  pexpect,
  python,
  replaceVars,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "bash-kernel";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "takluyver";
    repo = "bash_kernel";
    tag = version;
    hash = "sha256-ugFMcQx1B1nKoO9rhb6PMllRcoZi0O4B9um8dOu5DU4=";
  };

  patches = [
    (replaceVars ./bash-path.patch {
      bash = lib.getExe bashInteractive;
    })
  ];

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    runHook preCheck

    # Create a JUPYTER_PATH with the kernelspec
    export JUPYTER_PATH=$(mktemp -d)
    mkdir -p $JUPYTER_PATH/kernels/bash
    echo '{ "language": "bash", "argv": [ "${python}/bin/python", "-m", "bash_kernel", "-f", "{connection_file}" ] }' > $JUPYTER_PATH/kernels/bash/kernel.json

    # Evaluate a test notebook with papermill
    cd $(mktemp -d)
    ${python.withPackages (ps: [ ps.papermill ])}/bin/papermill --kernel bash ${./test.ipynb} out.ipynb

    runHook postCheck
  '';

  postInstall = ''
    ${python.pythonOnBuildForHost.interpreter} -m bash_kernel.install --prefix $out
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ flit-core ];

  dependencies = [
    filetype
    ipykernel
    pexpect
  ];

  pyproject = true;

  meta = {
    description = "Bash Kernel for Jupyter";
    homepage = "https://github.com/takluyver/bash_kernel";
    changelog = "https://github.com/takluyver/bash_kernel/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zimbatm ];
  };
}
