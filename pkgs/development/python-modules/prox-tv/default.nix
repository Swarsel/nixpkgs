{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  buildPythonPackage,
  cffi,
  lapack,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "prox-tv";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "albarji";
    repo = "proxTV";
    rev = "e621585d5aaa7983fbee68583f7deae995d3bafb";
    sha256 = "0mlrjbb5rw78dgijkr3bspmsskk6jqs9y7xpsgs35i46dvb327q5";
  };

  buildInputs = [
    blas
    lapack
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    cffi
  ];

  disabledTests = [ "test_tvp_1d" ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_tv2_1d" ];
  enableParallelBuilding = true;
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;

  meta = {
    description = "Toolbox for fast Total Variation proximity operators";
    homepage = "https://github.com/albarji/proxTV";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ multun ];
  };
}
