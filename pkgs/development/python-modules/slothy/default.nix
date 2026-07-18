{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gcc,
  llvm,
  ortools,
  setuptools,
  sympy,
  unicorn,
}:

buildPythonPackage rec {
  pname = "slothy";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "slothy-optimizer";
    repo = "slothy";
    tag = version;
    hash = "sha256-pyES6ithBVAFSVdjsM61kp6eeEUxNsLs7jdekpX+YuA=";
  };

  # slothy shells out to `gcc` and the llvm binutils at runtime; extend
  # PATH at import time so the library works in a plain withPackages env.
  postPatch = ''
      substituteInPlace slothy/__init__.py \
        --replace-fail 'from slothy.core.slothy import Slothy' \
          'import os
    os.environ["PATH"] = "${
      lib.makeBinPath [
        gcc
        llvm
      ]
    }" + os.pathsep + os.environ.get("PATH", "")
    from slothy.core.slothy import Slothy'
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    python3 test.py --silent --tests aarch64_simple0_a55
    runHook postInstallCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    ortools
    sympy
    unicorn
  ];

  pyproject = true;
  pythonImportsCheck = [ "slothy" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Assembly superoptimization via constraint solving";
    homepage = "https://slothy-optimizer.github.io/slothy";
    changelog = "https://github.com/slothy-optimizer/slothy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mkannwischer ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
