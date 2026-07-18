{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "patatt";
  version = "0.7.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-97K+ihXyUfu8kMa3NKuRBlSnqdGENpzp53ttJuQ7nuo=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pynacl
  ];

  pyproject = true;
  pythonImportsCheck = [ "patatt" ];

  meta = {
    description = "Add cryptographic attestation to patches sent via email";

    longDescription = ''
      This utility allows an easy way to add end-to-end cryptographic
      attestation to patches sent via mail.  It does so by adapting the
      DKIM email signature standard to include cryptographic
      signatures via the X-Developer-Signature email header.
    '';

    homepage = "https://git.kernel.org/pub/scm/utils/patatt/patatt.git/about/";
    license = lib.licenses.mit0;

    maintainers = with lib.maintainers; [
      qyliss
      yoctocell
    ];

    mainProgram = "patatt";
  };
})
