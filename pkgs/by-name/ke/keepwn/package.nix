{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "keepwn";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "Orange-Cyberdefense";
    repo = "KeePwn";
    tag = finalAttrs.version;
    hash = "sha256-z2+l7zOexcqbwkrdmB3EcYIjnGlproINF51Pcpp7Nz4=";
  };

  # Project has no tests
  doCheck = false;

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mv $out/bin/KeePwn $out/bin/$pname
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    chardet
    impacket
    lxml
    pefile
    pykeepass
    python-magic
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "keepwn" ];

  meta = {
    description = "Tool to automate KeePass discovery and secret extraction";
    homepage = "https://github.com/Orange-Cyberdefense/KeePwn";
    changelog = "https://github.com/Orange-Cyberdefense/KeePwn/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "keepwn";
  };
})
