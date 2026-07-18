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
  pytest,
  python,
  scikit-build-core,
  # Build tests to verify cross-compilation works, but only when CPU bit
  # depth matches (otherwise Python headers cause LONG_BIT mismatch errors)
  buildTests ? stdenv.hostPlatform.parsed.cpu.bits == stdenv.buildPlatform.parsed.cpu.bits,
}:
let
  setupHook = makeSetupHook {
    name = "pybind11-setup-hook";

    substitutions = {
      out = placeholder "out";
      pythonIncludeDir = "${python}/include/${python.libPrefix}";
      pythonInterpreter = python.pythonOnBuildForHost.interpreter;
      pythonSitePackages = "${python}/${python.sitePackages}";
    };

    meta.license = lib.licenses.mit;
  } ./setup-hook.sh;
in
buildPythonPackage (finalAttrs: {
  pname = "pybind11";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "pybind";
    repo = "pybind11";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QZKnIOopEDsiRFkc1qQ+DaDHoTNuEEgQVeiAL0sQqak=";
  };

  buildInputs = lib.optionals buildTests [
    catch2
    boost
    eigen
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" buildTests)

    # Override the `PYBIND11_NOPYTHON = true` in `pyproject.toml`. This
    # is required to build the tests.
    (lib.cmakeBool "PYBIND11_NOPYTHON" (!buildTests))
  ];

  nativeCheckInputs = [
    numpy
    pytest
  ];

  checkPhase = "ninjaCheckPhase";

  # Make the headers and CMake/pkg-config files inside the wheel
  # discoverable. This simulates the effect of the `pybind11[global]`
  # installation but works better for our build.
  postInstall = ''
    ln -s $out/${python.sitePackages}/pybind11/{include,share} $out/
  '';

  build-system = [
    cmake
    ninja
    finalAttrs.passthru.scikit-build-core-no-tests
  ];

  checkTarget = "check";
  dontUseCmakeConfigure = true;
  hardeningDisable = lib.optional stdenv.hostPlatform.isMusl "fortify";

  ninjaFlags = [
    "-C"
    "build"
  ];

  propagatedNativeBuildInputs = [ setupHook ];

  pypaBuildFlags = [
    # Keep the build directory around to run the tests.
    "-Cbuild-dir=build"
  ];

  pyproject = true;

  passthru = {
    # scikit-build-core's tests depend upon pybind11, and hence introduce
    # infinite recursion. To avoid this, we define here a scikit-build-core
    # derivation that doesn't depend on pybind11, and use it for pybind11's
    # build-system.
    scikit-build-core-no-tests = scikit-build-core.overridePythonAttrs {
      doCheck = false;
    };
  };

  meta = {
    description = "Seamless operability between C++11 and Python";

    longDescription = ''
      Pybind11 is a lightweight header-only library that exposes
      C++ types in Python and vice versa, mainly to create Python
      bindings of existing C++ code.
    '';

    homepage = "https://github.com/pybind/pybind11";
    changelog = "https://github.com/pybind/pybind11/blob/${finalAttrs.src.tag}/docs/changelog.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      yuriaisaka
      dotlambda
    ];

    mainProgram = "pybind11-config";
  };
})
