{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ldeep";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "franc-pentest";
    repo = "ldeep";
    tag = finalAttrs.version;
    hash = "sha256-VTgH/Wgk+0GY+jwZPEdMroQwKzliUjEzhrYU82lyOu0=";
  };

  nativeBuildInputs = with python3.pkgs; [ cython ];
  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ pdm-backend ];

  dependencies = with python3.pkgs; [
    commandparse
    cryptography
    dnspython
    gssapi
    ldap3-bleeding-edge
    oscrypto
    pycryptodome
    pycryptodomex
    six
    termcolor
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "ldeep" ];

  pythonRelaxDeps = [
    "termcolor"
    "cryptography"
    "ldap3-bleeding-edge"
  ];

  meta = {
    description = "In-depth LDAP enumeration utility";
    homepage = "https://github.com/franc-pentest/ldeep";
    changelog = "https://github.com/franc-pentest/ldeep/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ldeep";
  };
})
