{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  bzip2,
  cmake,
  cython,
  editline,
  gitpython,
  haskellPackages,
  libedit,
  libz,
  pcre2,
  pytestCheckHook,
  readline,
  requests,
  scikit-build,
  setuptools,
  twine,
}:

buildPythonPackage rec {
  pname = "pcre2-py";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "grtetrault";
    repo = "pcre2.py";
    tag = "v${version}";
    hash = "sha256-XSEYhVxOZnioFEX5kdODwF8SbPm5k6+TENsdOH9Yr1k=";
    fetchSubmodules = false;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_subdirectory(src/libpcre2)" "" \
      --replace-fail "install" "#install"
    substituteInPlace src/pcre2/CMakeLists.txt \
      --replace-fail "\''${PCRE2_INCLUDE_DIR}" "${pcre2.dev}/include" \
      --replace-fail "pcre2-8-static" "pcre2-8"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    twine
    gitpython
  ];

  postCheck = ''
    cd $out
    rm -rf *.t* *.py requirements Makefile LICENSE *.md
  '';

  build-system = [
    cmake
    cython
    scikit-build
    setuptools
  ];

  dependencies = [
    haskellPackages.bz2
    haskellPackages.memfd
  ]
  ++ [
    build
    bzip2
    editline
    libedit
    libz
    pcre2
    readline
    requests
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pcre2" ];

  meta = {
    description = "Python bindings for the PCRE2 library created by Philip Hazel";
    homepage = "https://github.com/grtetrault/pcre2.py";
    changelog = "https://github.com/grtetrault/pcre2.py/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tochiaha ];
  };
}
