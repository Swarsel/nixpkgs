{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  packaging,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asterisk-mbox";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BiT5q4XOnE1DZV+GU+hTn6EMgbYP17lLGhXc4wbCCIg=";
    pname = "asterisk_mbox";
  };

  patches = [
    # https://github.com/PhracturedBlue/asterisk_mbox/pull/1
    (fetchpatch2 {
      hash = "sha256-2j7jIl3Ydn2dHJhEzu/77Zkxhw58NIebgULifpTVidY=";
      name = "distutils-deprecated.patch";
      url = "https://github.com/PhracturedBlue/asterisk_mbox/commit/bab84525306a0c41aadd3aab4ebba7c062253d07.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ packaging ];
  # no tests implemented
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "asterisk_mbox" ];

  meta = {
    description = "Client side of a client/server to interact with Asterisk voicemail mailboxes";
    homepage = "https://github.com/PhracturedBlue/asterisk_mbox";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
