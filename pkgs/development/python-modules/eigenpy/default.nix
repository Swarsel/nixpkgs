{
  lib,
  fetchFromGitHub,
  # buildInputs
  boost,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  doxygen,
  # propagatedBuildInputs
  eigen,
  fontconfig,
  graphviz,
  jrl-cmakemodules,
  numpy,
  pkg-config,
  scipy,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "eigenpy";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "stack-of-tasks";
    repo = "eigenpy";
    tag = "v${version}";
    hash = "sha256-05G0U1RjVwggfnABxZH+9kxDIo7M9rgxHCcTvNgTZCQ=";
  };

  outputs = [
    "dev"
    "doc"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    pkg-config
    scipy
    writableTmpDirAsHomeHook
  ];

  buildInputs = [ boost ];

  propagatedBuildInputs = [
    eigen
    jrl-cmakemodules
    numpy
  ];

  cmakeFlags = [
    "-DINSTALL_DOCUMENTATION=ON"
    "-DBUILD_TESTING=ON"
    "-DBUILD_TESTING_SCIPY=ON"
  ];

  # Fontconfig error: Cannot load default config file: No such file: (null)
  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";

  preInstallCheck = ''
    make test
  '';

  pyproject = false; # Built with cmake
  pythonImportsCheck = [ "eigenpy" ];

  meta = {
    description = "Bindings between Numpy and Eigen using Boost.Python";
    homepage = "https://github.com/stack-of-tasks/eigenpy";
    changelog = "https://github.com/stack-of-tasks/eigenpy/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      nim65s
      wegank
    ];

    platforms = lib.platforms.unix;
  };
}
