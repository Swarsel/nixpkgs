{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  oldest-supported-numpy,
  pyparsing,
  pytestCheckHook,
  python-lzo,
  setuptools,
  zlib,
}:

buildPythonPackage rec {
  pname = "bx-python";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "bxlab";
    repo = "bx-python";
    tag = "v${version}";
    hash = "sha256-WZjCPggAlC+L/SagC4TXJXNrFG85BmjO7FaV2GxrYYA=";
  };

  postPatch = ''
    # pytest-cython, which provides this option, isn't packaged
    substituteInPlace pytest.ini \
      --replace-fail "--doctest-cython" ""
  '';

  buildInputs = [ zlib ];
  # https://github.com/bxlab/bx-python/issues/101
  doCheck = false;

  nativeCheckInputs = [
    python-lzo
    pytestCheckHook
  ];

  postInstall = ''
    cp -r scripts/* $out/bin

    # This is a small hack; the test suite uses the scripts which need to
    # be patched. Linking the patched scripts in $out back to the
    # working directory allows the tests to run
    rm -rf scripts
    ln -s $out/bin scripts
  '';

  build-system = [
    setuptools
    cython
    oldest-supported-numpy
  ];

  dependencies = [
    numpy
    pyparsing
  ];

  pyproject = true;

  meta = {
    description = "Tools for manipulating biological data, particularly multiple sequence alignments";
    homepage = "https://github.com/bxlab/bx-python";
    changelog = "https://github.com/bxlab/bx-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = [ "x86_64-linux" ];
  };
}
