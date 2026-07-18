{
  lib,
  # build-system
  build,
  buildPythonPackage,
  # build-time
  cmake,
  libgdstk,
  # deps (optional)
  matplotlib,
  ninja,
  # deps
  numpy,
  # tests
  pytestCheckHook,
  qhull,
  scikit-build-core,
  sphinx,
  sphinx-inline-tabs,
  sphinx-rtd-theme,
  typing-extensions,
  # run-time
  zlib,
}:

buildPythonPackage {
  inherit (libgdstk) src version;
  pname = "gdstk";
  strictDeps = true;

  buildInputs = [
    zlib
    qhull
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # remove the `gdstk` source directory, else pytest will attempt to import it
  # instead of the actual module
  preCheck = ''
    rm -rf gdstk
  '';

  build-system = [
    build
    cmake
    ninja
    numpy
    scikit-build-core
  ];

  dependencies = [
    numpy
    typing-extensions
  ];

  # scikit is supposed to handle the module build
  dontUseCmakeConfigure = true;

  optional-dependencies = {
    docs = [
      matplotlib
      sphinx
      sphinx-inline-tabs
      sphinx-rtd-theme
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "gdstk"
  ];

  meta = {
    inherit (libgdstk.meta)
      description
      homepage
      changelog
      license
      maintainers
      teams
      ;
  };
}
