{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  pillow,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fabulous";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "jart";
    repo = "fabulous";
    rev = version;
    hash = "sha256-hchlxuB5QP+VxCx+QZ2739/mR5SQmYyE+9kXLKJ2ij4=";
  };

  patches = [
    ./relative_import.patch
    # https://github.com/jart/fabulous/pull/22
    (fetchpatch2 {
      hash = "sha256-miWFt4vDpwWhSUgnWDjWUXoibijcDa1c1dDOSkfWoUg=";
      url = "https://github.com/jart/fabulous/commit/5779f2dfbc88fd81b5b5865247913d4775e67959.patch?full_index=1";
    })
  ];

  checkPhase = ''
    for i in tests/*.py; do
      ${python.interpreter} $i
    done
  '';

  build-system = [ setuptools ];
  dependencies = [ pillow ];
  pyproject = true;

  meta = {
    description = "Make the output of terminal applications look fabulous";
    homepage = "https://jart.github.io/fabulous";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.symphorien ];
  };
}
