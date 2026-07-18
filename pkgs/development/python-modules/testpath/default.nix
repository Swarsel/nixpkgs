{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "testpath";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LxuX5kQsAmgevgG9hPUxAop8rqGvOCUAD1I0XDAoXg8=";
  };

  nativeBuildInputs = [ flit-core ];

  # exe are only required when testpath is used on windows
  # https://github.com/jupyter/testpath/blob/de8ca59539eb23b9781e55848b7d2646c8c61df9/testpath/commands.py#L128
  preBuild = lib.optionalString (!stdenv.hostPlatform.isWindows) ''
    rm testpath/cli-32.exe testpath/cli-64.exe
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Work around https://github.com/jupyter/testpath/issues/24
    export TMPDIR="/tmp"
  '';

  pyproject = true;

  meta = {
    description = "Test utilities for code working with files and commands";
    homepage = "https://github.com/jupyter/testpath";
    license = lib.licenses.mit;
  };
}
