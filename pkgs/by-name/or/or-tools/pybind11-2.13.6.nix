# This is pybind11 2.13.6 from an earlier nixpkgs version, with the
# parts from https://github.com/google/or-tools/commit/7f29b27840436e19b6530d5c7f23eeadd819bd3e
# applied.
{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  buildPythonPackage,
  catch2,
  cmake,
  eigen,
  makeSetupHook,
  ninja,
  numpy,
  pytestCheckHook,
  python,
  setuptools,
}:
let
  setupHook = makeSetupHook {
    name = "pybind11-setup-hook";

    substitutions = {
      out = placeholder "out";
      pythonIncludeDir = "${python}/include/python${python.pythonVersion}";
      pythonInterpreter = python.pythonOnBuildForHost.interpreter;
      pythonSitePackages = "${python}/${python.sitePackages}";
    };

    meta.license = lib.licenses.mit;
  } ./pybind11-setup-hook.sh;
in
buildPythonPackage (finalAttrs: {
  pname = "pybind11";
  version = "2.13.6";

  src = fetchFromGitHub {
    owner = "pybind";
    repo = "pybind11";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SNLdtrOjaC3lGHN9MAqTf51U9EzNKQLyTMNPe0GcdrU=";
  };

  # https://github.com/google/or-tools/commit/7f29b27840436e19b6530d5c7f23eeadd819bd3e
  patches = [ ./pybind11.patch ];

  cmakeFlags = [
    "-DBoost_INCLUDE_DIR=${lib.getDev boost}/include"
    "-DCATCH_INCLUDE_DIR=${lib.getDev catch2}/include/catch2"
    "-DEIGEN3_INCLUDE_DIR=${lib.getDev eigen}/include/eigen3"
  ]
  ++ lib.optionals (python.isPy3k && !stdenv.cc.isClang) [ "-DPYBIND11_CXX_STANDARD=-std=c++17" ];

  # Don't build tests if not needed, read the doInstallCheck value at runtime
  preConfigure = ''
    if [ -n "$doInstallCheck" ]; then
      cmakeFlagsArray+=("-DBUILD_TESTING=ON")
    fi
  '';

  postBuild = ''
    # build tests
    make -j $NIX_BUILD_CORES
  '';

  nativeCheckInputs = [
    catch2
    numpy
    pytestCheckHook
  ];

  postCheck = ''
    make cpptest
  '';

  postInstall = ''
    make install
    # Symlink the CMake-installed headers to the location expected by setuptools
    mkdir -p $out/include/${python.libPrefix}
    ln -sf $out/include/pybind11 $out/include/${python.libPrefix}/pybind11
  '';

  build-system = [
    cmake
    ninja
    setuptools
  ];

  disabledTestPaths = [
    # require dependencies not available in nixpkgs
    "tests/test_embed/test_trampoline.py"
    "tests/test_embed/test_interpreter.py"
    # numpy changed __repr__ output of numpy dtypes
    "tests/test_numpy_dtypes.py"
    # no need to test internal packaging
    "tests/extra_python_package/test_files.py"
    # tests that try to parse setuptools stdout
    "tests/extra_setuptools/test_setuphelper.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # expects KeyError, gets RuntimeError
    # https://github.com/pybind/pybind11/issues/4243
    "test_cross_module_exception_translator"
  ];

  dontUseCmakeBuildDir = true;
  hardeningDisable = lib.optional stdenv.hostPlatform.isMusl "fortify";
  propagatedNativeBuildInputs = [ setupHook ];
  pyproject = true;

  meta = {
    description = "Seamless operability between C++11 and Python";

    longDescription = ''
      Pybind11 is a lightweight header-only library that exposes
      C++ types in Python and vice versa, mainly to create Python
      bindings of existing C++ code.
    '';

    homepage = "https://github.com/pybind/pybind11";
    changelog = "https://github.com/pybind/pybind11/blob/${finalAttrs.src.rev}/docs/changelog.rst";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      yuriaisaka
      dotlambda
    ];

    mainProgram = "pybind11-config";
  };
})
