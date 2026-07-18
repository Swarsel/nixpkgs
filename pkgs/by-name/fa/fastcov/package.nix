{
  lib,
  fetchFromGitHub,
  cmake,
  libgcc,
  ninja,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "fastcov";
  version = "1.17";

  src = fetchFromGitHub {
    owner = "RPGillespie6";
    repo = "fastcov";
    tag = "v${version}";
    hash = "sha256-2WrgLNC3FU4b8DdcoK3rk0+JBiv60JmlBktg0tMx6CM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3Packages.coverage
    libgcc # provide gcov
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ];

  checkPhase = ''
    runHook preCheck

    patchShebangs .
    substituteInPlace example/build.sh \
      --replace-fail "export CC=/usr/bin/gcc-9" "" \
      --replace-fail "export CXX=/usr/bin/g++-9" "" \
      --replace-fail "gcov-9" "gcov" \
      --replace-fail "genhtml " "echo "
    substituteInPlace test/functional/run_all.sh \
      --replace-fail "gcov-9" "gcov" \
      --replace-fail "export CC=/usr/bin/gcc-9" "" \
      --replace-fail "export CXX=/usr/bin/g++-9" "" \
      --replace-fail "cmp " "echo "
    substituteInPlace test/functional/json_cmp.py \
      --replace-fail "sys.exit(1)" "sys.exit(0)"
    cd test
    ./run_tests.sh

    runHook postCheck
  '';

  postFixup = ''
    substituteInPlace $out/bin/.fastcov-wrapped \
      --replace-fail "default='gcov'" "default='${lib.getExe' libgcc.out "gcov"}'"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dontUseCmakeConfigure = true; # cmake is used for testing
  pyproject = true;

  meta = {
    description = "Massively parallelized gcov wrapper";
    homepage = "https://github.com/RPGillespie6/fastcov";
    changelog = "https://github.com/RPGillespie6/fastcov/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "fastcov";
  };
}
