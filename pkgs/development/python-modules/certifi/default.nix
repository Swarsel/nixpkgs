{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cacert,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "certifi";
  version = "2026.04.22";

  src = fetchFromGitHub {
    owner = "certifi";
    repo = "python-certifi";
    tag = finalAttrs.version;
    hash = "sha256-bGeOrYd7ZUG0VIbgRiYIBK3JDRC5wpST5IrFHyWO/cg=";
  };

  patches = [
    # Add support for NIX_SSL_CERT_FILE
    ./env.patch
  ];

  postPatch = ''
    # Use our system-wide ca-bundle instead of the bundled one
    rm -v "certifi/cacert.pem"
    ln -snvf "${cacert}/etc/ssl/certs/ca-bundle.crt" "certifi/cacert.pem"
  '';

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  propagatedNativeBuildInputs = [
    # propagate cacerts setup-hook to set up `NIX_SSL_CERT_FILE`
    cacert
  ];

  pyproject = true;
  pythonImportsCheck = [ "certifi" ];

  meta = {
    description = "Python package for providing Mozilla's CA Bundle";
    homepage = "https://github.com/certifi/python-certifi";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ koral ];
  };
})
