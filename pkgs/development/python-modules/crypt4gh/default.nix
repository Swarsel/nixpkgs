{
  lib,
  fetchFromGitHub,
  bats,
  bcrypt,
  buildPythonPackage,
  # deps
  cryptography,
  docopt,
  installShellFiles,
  openssh,
  pynacl,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "crypt4gh";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "EGA-archive";
    repo = "crypt4gh";
    rev = "v${version}";
    hash = "sha256-kPXD/SityWscHuRn068E6fFxUjt67cC5VEe5o8wtxwk=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    bats
    openssh
  ];

  postInstall = ''
    installShellCompletion \
      completions/crypt4gh-debug.bash \
      completions/crypt4gh-debug.bash \
      completions/crypt4gh.bash
  '';

  installCheckPhase = ''
    PATH=$PATH:$out/bin
    bats tests
  '';

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    docopt
    cryptography
    pynacl
    bcrypt
  ];

  pyproject = true;
  pythonImportsCheck = [ "crypt4gh" ];

  meta = {
    description = "Tool to encrypt, decrypt or re-encrypt files, according to the GA4GH encryption file format";
    homepage = "https://github.com/EGA-archive/crypt4gh";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.richardjacton ];
    platforms = lib.platforms.all;
    mainProgram = "crypt4gh";
  };
}
