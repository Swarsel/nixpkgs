{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  boost183,
  cmake,
  flex,
  libseccomp,
  makeShellWrapper,
  python3Packages,
  swig,
}:

python3Packages.buildPythonApplication rec {
  pname = "grap";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "QuoSecGmbH";
    repo = "grap";
    tag = "v${version}";
    hash = "sha256-zLIKoNOdrmTyZkQGRogeKfIRk4kpG0hmeN0519SJbbo=";
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
     --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"

    substituteInPlace src/tools/grap-match/CMakeLists.txt --replace-fail "/usr/local/bin" "$out/bin"

    substituteInPlace src/tools/grap/CMakeLists.txt --replace-fail "/usr/local/bin" "$out/bin"

    substituteInPlace src/bindings/python/CMakeLists.txt --replace-fail "distutils" "setuptools._distutils"

    substituteInPlace src/tools/setup.py --replace-fail "distutils.core" "setuptools"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    cmake
    flex
    swig
    makeShellWrapper
  ];

  buildInputs = [
    libseccomp
  ]
  ++ boost183.all;

  cmakeFlags = [
    "-DPYTHON_SITE_DIR=${placeholder "out"}/${python3Packages.python.sitePackages}"
    "../src"
  ];

  postInstall = ''
    cd $out/${python3Packages.python.sitePackages}

    substituteInPlace pygrap.py \
      --replace-fail "import imp" "import importlib" \
      --replace-fail "imp." "importlib."
  '';

  dependencies = with python3Packages; [
    setuptools
    capstone
  ];

  pyproject = false;

  meta = {
    description = "Define and match graph patterns within binaries";

    longDescription = ''
      grap takes patterns and binary files, uses a Casptone-based disassembler to obtain the control flow graphs from the binaries, then matches the patterns against them.

      Patterns are user-defined graphs with instruction conditions ("opcode is xor and arg1 is eax") and repetition conditions (3 identical instructions, basic blocks...).
    '';

    homepage = "https://github.com/QuoSecGmbH/grap/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ s1341 ];
    platforms = lib.platforms.linux;
    mainProgram = "grap";
  };
}
