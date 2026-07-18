{
  lib,
  fetchFromGitHub,
  awscli,
  groff,
  less,
  nix-update-script,
  python3Packages,
  testers,
  versionCheckHook,
}:

let
  self = python3Packages.buildPythonApplication (finalAttrs: {
    pname = "awscli";
    # N.B: if you change this, change botocore and boto3 to a matching version too
    # check e.g. https://github.com/aws/aws-cli/blob/1.33.21/setup.py
    version = "1.44.21";

    src = fetchFromGitHub {
      owner = "aws";
      repo = "aws-cli";
      tag = finalAttrs.version;
      hash = "sha256-yQFK1YjehmACZGMXfMQLc5OiiIGDO08OtwFSpaRyi58=";
    };

    postInstall = ''
      mkdir -p $out/share/bash-completion/completions
      echo "complete -C $out/bin/aws_completer aws" > $out/share/bash-completion/completions/awscli

      mkdir -p $out/share/zsh/site-functions
      mv $out/bin/aws_zsh_completer.sh $out/share/zsh/site-functions

      rm $out/bin/aws.cmd
    '';

    doInstallCheck = true;

    nativeInstallCheckInputs = [
      versionCheckHook
    ];

    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/aws --version | grep "${python3Packages.botocore.version}"
      $out/bin/aws --version | grep "${finalAttrs.version}"

      runHook postInstallCheck
    '';

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      botocore
      docutils
      s3transfer
      pyyaml
      colorama
      rsa

      groff
      less
    ];

    pyproject = true;

    pythonRelaxDeps = [
      # botocore must not be relaxed
      "docutils"
      "rsa"
    ];

    passthru = {
      python = python3Packages.python; # for aws_shell

      updateScript = nix-update-script {
        extraArgs = [ "--version=skip" ];
      };
    };

    meta = {
      description = "Unified tool to manage your AWS services";
      homepage = "https://aws.amazon.com/cli/";
      changelog = "https://github.com/aws/aws-cli/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ anthonyroussel ];
      mainProgram = "aws";
    };
  });
in
assert self ? pythonRelaxDeps -> !(lib.elem "botocore" self.pythonRelaxDeps);
self
