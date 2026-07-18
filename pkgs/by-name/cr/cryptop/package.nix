{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cryptop";
  version = "0.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0akrrz735vjfrm78plwyg84vabj0x3qficq9xxmy9kr40fhdkzpb";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    requests
    requests-cache
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Command line Cryptocurrency Portfolio";
    homepage = "https://github.com/huwwp/cryptop";
    license = lib.licenses.mit;
    mainProgram = "cryptop";
  };
})
