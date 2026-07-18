{
  lib,
  fetchFromGitHub,
  cacert,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "nix-playground";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "nix-playground";
    tag = finalAttrs.version;
    hash = "sha256-WiQlqQHW4RNvk79cs3B6+Tg1STYXj2tq2+Pvu82saxk=";
  };

  # Tests require certificates
  # https://github.com/NixOS/nixpkgs/pull/72544#issuecomment-582674047
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    hatchling
  ];

  dependencies = with python3.pkgs; [
    click
    pygit2
    rich
  ];

  disabledTestPaths = [
    # Disable tests that require nix store
    "tests/acceptance/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nix_playground" ];

  meta = {
    description = "Command line tools for patching nixpkgs package source code easily";
    homepage = "https://github.com/LaunchPlatform/nix-playground";
    changelog = "https://github.com/LaunchPlatform/nix-playground/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fangpen ];
    mainProgram = "np";
  };
})
