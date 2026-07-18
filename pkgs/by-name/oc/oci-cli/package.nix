{
  lib,
  fetchFromGitHub,
  fetchPypi,
  installShellFiles,
  nix-update-script,
  python3,
  versionCheckHook,
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      jmespath = super.jmespath.overridePythonAttrs (oldAttrs: rec {
        version = "0.10.0";

        src =
          fetchPypi {
            inherit version;
            sha256 = "b85d0567b8666149a93172712e68920734333c0ce7e89b78b3e987f71e5ed4f9";
            pname = "jmespath";
          }
          // {
            tag = version;
          };

        doCheck = false;
      });
    };

    self = py;
  };
in

py.pkgs.buildPythonApplication (finalAttrs: {
  pname = "oci-cli";
  version = "3.89.1";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "oci-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9sr+7zFP7THy39XWWI8bC2Th9e2t6zwfjbBkyajvOHM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  doCheck = true;

  postInstall = ''
    cat >oci.zsh <<EOF
    #compdef oci
    zmodload -i zsh/parameter
    autoload -U +X bashcompinit && bashcompinit
    if ! (( $+functions[compdef] )) ; then
        autoload -U +X compinit && compinit
    fi

    EOF
    cat src/oci_cli/bin/oci_autocomplete.sh >>oci.zsh

    installShellCompletion \
      --cmd oci \
      --bash src/oci_cli/bin/oci_autocomplete.sh \
      --zsh oci.zsh
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];

  # Propagating dependencies leaks them through $PYTHONPATH which causes issues
  # when used in nix-shell.
  postFixup = ''
    rm $out/nix-support/propagated-build-inputs
  '';

  build-system = with py.pkgs; [
    setuptools
  ];

  dependencies = with py.pkgs; [
    arrow
    certifi
    click
    cryptography
    jmespath
    oci
    prompt-toolkit
    pyopenssl
    python-dateutil
    pytz
    pyyaml
    retrying
    six
    terminaltables
    urllib3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "oci_cli"
  ];

  pythonRelaxDeps = [
    "setuptools"
    "click"
    "PyYAML"
    "cryptography"
    "oci"
    "prompt-toolkit"
    "pyOpenSSL"
    "terminaltables"
    "certifi"
    "pytz"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command Line Interface for Oracle Cloud Infrastructure";
    homepage = "https://docs.cloud.oracle.com/iaas/Content/API/Concepts/cliconcepts.htm";
    changelog = "https://github.com/oracle/oci-cli/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20 # or
      upl
    ];

    maintainers = with lib.maintainers; [
      ilian
      FKouhai
    ];

    mainProgram = "oci";
  };
})
