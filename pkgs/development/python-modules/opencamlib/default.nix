{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  buildPythonPackage,
  cmake,
  llvmPackages,
  ninja,
  python,
  scikit-build-core,
}:

buildPythonPackage rec {
  pname = "opencamlib";
  version = "2023.01.11";

  src = fetchFromGitHub {
    owner = "aewallin";
    repo = "opencamlib";
    tag = version;
    hash = "sha256-pUj71PdWo902dqF9O6SLnpvFooFU2OfLBv8hAVsH/iA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "2022.12.18"' 'version = "${version}"'
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  env.CMAKE_ARGS = "-DVERSION_STRING=${version} -DBoost_USE_STATIC_LIBS=OFF";

  checkPhase = ''
    runHook preCheck

    pushd examples/python
    # this produces a lot of non-actionalble lines on stdout
    ${python.interpreter} test.py > /dev/null
    popd

    runHook postCheck
  '';

  build-system = [
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "opencamlib" ];

  meta = {
    description = "Open source computer aided manufacturing algorithms library";
    homepage = "https://github.com/aewallin/opencamlib";
    # from src/deb/debian_copyright.txt
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ tomjnixon ];
  };
}
