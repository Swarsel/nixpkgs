{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fetchpatch,
  numpy,
  # Check Inputs
  pytestCheckHook,
  python,
}:

buildPythonPackage rec {
  pname = "fastdtw";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "slaypni";
    repo = "fastdtw";
    rev = "v${version}";
    sha256 = "0irc5x4ahfp7f7q4ic97qa898s2awi0vdjznahxrfjirn8b157dw";
  };

  patches = [
    # Removes outdated cythonized C++ file, which doesn't match CPython. Will be auto-used if left.
    # Remove when PR 40 merged
    (fetchpatch {
      sha256 = "0xjma0h84bk1n32wgk99rwfc85scp187a7fykhnylmcc73ppal9q";
      url = "https://patch-diff.githubusercontent.com/raw/slaypni/fastdtw/pull/40.patch";
    })
  ];

  nativeBuildInputs = [ cython ];
  propagatedBuildInputs = [ numpy ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    echo "Temporarily moving tests to $OUT to find cython modules"
    export PACKAGEDIR=$out/${python.sitePackages}
    cp -r $TMP/source/tests $PACKAGEDIR
    pushd $PACKAGEDIR
  '';

  postCheck = ''
    rm -rf tests
    popd
  '';

  format = "setuptools";
  pythonImportsCheck = [ "fastdtw.fastdtw" ];

  meta = {
    description = "Python implementation of FastDTW (Dynamic Time Warping)";

    longDescription = ''
      FastDTW is an approximate Dynamic Time Warping (DTW) algorithm that provides
      optimal or near-optimal alignments with an O(N) time and memory complexity.
    '';

    homepage = "https://github.com/slaypni/fastdtw";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
