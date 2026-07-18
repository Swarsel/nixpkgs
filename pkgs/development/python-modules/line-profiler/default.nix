{
  lib,
  buildPythonPackage,
  cmake,
  cython,
  fetchPypi,
  ipython,
  isPyPy,
  pytestCheckHook,
  scikit-build,
  ubelt,
}:

buildPythonPackage rec {
  pname = "line-profiler";
  version = "5.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-qA8K+wW6DSddnd3F/5fqtjdHEWf/Pmbcx9E1dVBZOYw=";
    pname = "line_profiler";
  };

  nativeBuildInputs = [
    cython
    cmake
    scikit-build
  ];

  preBuild = ''
    rm -f _line_profiler.c
  '';

  nativeCheckInputs = [
    pytestCheckHook
    ubelt
  ]
  ++ optional-dependencies.ipython;

  preCheck = ''
    rm -r line_profiler
    export PATH=$out/bin:$PATH
  '';

  disabled = isPyPy;
  dontUseCmakeConfigure = true;
  format = "setuptools";

  optional-dependencies = {
    ipython = [ ipython ];
  };

  pythonImportsCheck = [ "line_profiler" ];

  meta = {
    description = "Line-by-line profiler";
    homepage = "https://github.com/pyutils/line_profiler";
    changelog = "https://github.com/pyutils/line_profiler/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    mainProgram = "kernprof";
  };
}
