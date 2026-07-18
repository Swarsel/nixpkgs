{
  lib,
  fetchPypi,
  git,
  mercurial,
  python3Packages,
}:

with python3Packages;

buildPythonApplication (finalAttrs: {
  pname = "mbed-cli";
  version = "1.10.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-X+hNVM8fsy0VFTqFr1pPKWRimacBenTcY4y+PBJpvlI=";
  };

  nativeCheckInputs = [
    git
    mercurial
    pytest
  ];

  checkPhase = ''
    export GIT_COMMITTER_NAME=nixbld
    export EMAIL=nixbld@localhost
    export GIT_COMMITTER_DATE=$SOURCE_DATE_EPOCH
    pytest test
  '';

  format = "setuptools";

  meta = {
    description = "Arm Mbed Command Line Interface";
    homepage = "https://github.com/ARMmbed/mbed-cli";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
