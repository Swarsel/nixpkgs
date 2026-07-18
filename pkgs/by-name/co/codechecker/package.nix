{
  lib,
  clang-tools,
  cppcheck,
  fetchPypi,
  gcc,
  infer,
  libclang,
  makeWrapper,
  python3Packages,
  withClang ? false,
  withClangTools ? false,
  withCppcheck ? false,
  withGcc ? false,
  withInfer ? false,
}:
python3Packages.buildPythonApplication rec {
  pname = "codechecker";
  version = "6.28.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wxV+/hzsk7RrzWTXNz5HyweYdFFI1upNS508QRPCefo=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [
    makeWrapper
    pythonRelaxDepsHook
  ];

  postInstall = ''
    wrapProgram "$out/bin/CodeChecker" --prefix PATH : ${
      lib.makeBinPath (
        lib.optional withClang libclang
        ++ lib.optional withClangTools clang-tools
        ++ lib.optional withCppcheck cppcheck
        ++ lib.optional withGcc gcc
        ++ lib.optional withInfer infer
      )
    }
  '';

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    alembic
    argcomplete
    authlib
    distutils # required in python312 to call subcommands (see https://github.com/Ericsson/codechecker/issues/4350)
    lxml
    multiprocess
    portalocker
    psutil
    semver
    sqlalchemy
    thrift
    gitpython
    pyyaml
    requests
    types-pyyaml
    sarif-tools
    types-psutil
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "Analyzer tooling, defect database and viewer extension for the Clang Static Analyzer and Clang Tidy";
    homepage = "https://github.com/Ericsson/codechecker";
    changelog = "https://github.com/Ericsson/codechecker/releases/tag/v${version}";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = with lib.maintainers; [
      zebreus
      felixsinger
      kacper-uminski
    ];

    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "CodeChecker";
  };
}
