{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  doxygen,
  eigen,
  jrl-cmakemodules,
  nanobind,
  nix-update-script,
  # dependencies
  numpy,
  # checkInputs
  pytest,
  python,
  scipy,
  # propagatedBuildInputs
  suitesparse,
}:

buildPythonPackage rec {
  pname = "nanoeigenpy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Simple-Robotics";
    repo = "nanoeigenpy";
    tag = "v${version}";
    hash = "sha256-FWNIZFzY7BXC3vQKsIUFIJr3dQ8V1+OOmt5mKQP9/3M=";
  };

  outputs = [
    "dev"
    "doc"
    "out"
  ];

  # Fix:
  # > PermissionError: [Errno 13] Permission denied:
  # > '/nix/store/…-python3-3.12.9/lib/python3.12/site-packages/nanoeigenpy.pyi'
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "$""{Python_SITELIB}" \
      "${python.sitePackages}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    nanobind
  ];

  propagatedBuildInputs = [
    suitesparse
    eigen
    jrl-cmakemodules
  ];

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_DOCUMENTATION" true)
    (lib.cmakeBool "BUILD_TESTING" true)
    (lib.cmakeBool "BUILD_WITH_CHOLMOD_SUPPORT" true)
    # Accelerate support in eigen requires
    # https://gitlab.com/libeigen/eigen/-/merge_requests/856
    # which is not in the current eigen v3.4.0-unstable-2022-05-19
    # (lib.cmakeBool "BUILD_WITH_ACCELERATE_SUPPORT" stdenv.hostPlatform.isDarwin)
  ];

  checkInputs = [
    pytest
    scipy
  ];

  postFixup = ''
    substituteInPlace $dev/lib/cmake/nanoeigenpy/nanoeigenpyConfig.cmake \
      --replace-fail $out $dev
  '';

  dependencies = [
    numpy
  ];

  # Ensure the unit tests are built
  preInstallCheck = "make test";
  pyproject = false; # Built with cmake
  pythonImportsCheck = [ "nanoeigenpy" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Support library for bindings between Eigen in C++ and Python, based on nanobind";
    homepage = "https://github.com/Simple-Robotics/nanoeigenpy";
    changelog = "https://github.com/Simple-Robotics/nanoeigenpy/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
}
