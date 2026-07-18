{
  lib,
  fetchurl,
  buildPythonPackage,
  setuptools,
  sqlite,
}:

buildPythonPackage rec {
  pname = "apsw";
  version = "3.51.0.0";

  # https://github.com/rogerbinns/apsw/issues/548
  src = fetchurl {
    url = "https://github.com/rogerbinns/apsw/releases/download/${version}/apsw-${version}.tar.gz";
    hash = "sha256-8I1/HnGO9eOs9CUFwvN5BcpHtCxXD7qlF9WBA4E1Rls=";
  };

  buildInputs = [ sqlite ];

  # apsw explicitly doesn't use pytest
  # see https://github.com/rogerbinns/apsw/issues/548#issuecomment-2891633403
  checkPhase = ''
    runHook preCheck
    python -m apsw.tests
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "apsw" ];

  meta = {
    description = "Python wrapper for the SQLite embedded relational database engine";
    homepage = "https://github.com/rogerbinns/apsw";
    changelog = "https://github.com/rogerbinns/apsw/blob/${version}/doc/changes.rst";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ gador ];
  };
}
