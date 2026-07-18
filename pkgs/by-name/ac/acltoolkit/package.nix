{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "acltoolkit";
  version = "0.2.2-unstable-2023-02-03";

  src = fetchFromGitHub {
    owner = "zblurx";
    repo = "acltoolkit";
    # https://github.com/zblurx/acltoolkit/issues/6
    rev = "a5219946aa445c0a3b4a406baea67b33f78bca7c";
    hash = "sha256-97cbkGyIkq2Pk1hydMcViXWoh+Ipi3m0YvEYiaV4zcM=";
  };

  postPatch = ''
    # Ignore pinned versions
    sed -i -e "s/==[0-9.]*//" setup.py
  '';

  # Project has no tests
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    asn1crypto
    dnspython
    impacket
    ldap3
    pyasn1
    pycryptodome
  ];

  pyproject = true;
  pythonImportsCheck = [ "acltoolkit" ];

  meta = {
    description = "ACL abuse swiss-knife";
    homepage = "https://github.com/zblurx/acltoolkit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "acltoolkit";
  };
})
