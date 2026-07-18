{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "starline";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F1P1/NKml2rtd1r7A/g5IVnwQMZzkXzAxjRRDZXBPLk=";
  };

  patches = [
    # https://github.com/Anonym-tsk/starline/pull/5
    (fetchpatch {
      hash = "sha256-y9b6ePH3IEgmt3ALHQGwH102rlm4KfmH4oIoIC93cWU=";
      url = "https://github.com/Anonym-tsk/starline/commit/4e6cdf8e05c5fb8509ee384e77b39a2495587160.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ requests ];
  # no tests implemented
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "starline" ];
  # https://github.com/Anonym-tsk/starline/issues/4
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Unofficial python library for StarLine API";
    homepage = "https://github.com/Anonym-tsk/starline";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
