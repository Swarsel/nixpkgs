{
  lib,
  fetchFromGitHub,
  buildAndTestSubdir,
  buildPythonPackage,
  # These are always passed as an override or as a callPackage option.
  nativeBuildInputs,
  preConfigure,
  pyproject,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  inherit
    buildAndTestSubdir
    pyproject
    nativeBuildInputs
    preConfigure
    ;

  pname = "word-count";
  version = "0.28.2";

  src = fetchFromGitHub {
    owner = "PyO3";
    repo = "pyo3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jg+eni7I0jVUFViWbgj5F094ksvyuvF4mdgGzh0PMaQ=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  pythonImportsCheck = [ "word_count" ];

  meta = {
    description = "PyO3 word count example";
    homepage = "https://github.com/PyO3/pyo3";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
