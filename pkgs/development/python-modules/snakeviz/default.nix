{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipython,
  pytestCheckHook,
  requests,
  setuptools,
  tornado,
}:

buildPythonPackage rec {
  pname = "snakeviz";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "jiffyclub";
    repo = "snakeviz";
    tag = "v${version}";
    hash = "sha256-s/OATRnkooucRkLer5A66X9xDEA7aKNo+c10m1N7Guw=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ tornado ];

  nativeCheckInputs = [
    ipython
    pytestCheckHook
    requests
  ];

  preCheck = ''
    export PATH="$PATH:$out/bin";
    export HOME="$PWD/.home"
    mkdir -p "$HOME"
  '';

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pythonImportsCheck = [ "snakeviz" ];

  meta = {
    description = "Browser based viewer for profiling data";
    homepage = "https://jiffyclub.github.io/snakeviz";
    changelog = "https://github.com/jiffyclub/snakeviz/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      nixy
      pbsds
    ];

    mainProgram = "snakeviz";
  };
}
