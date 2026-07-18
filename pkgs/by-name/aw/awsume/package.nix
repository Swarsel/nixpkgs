{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "awsume";
  version = "4.5.5";

  src = fetchFromGitHub {
    owner = "trek10inc";
    repo = "awsume";
    tag = finalAttrs.version;
    hash = "sha256-lm9YANYckyHDoNbB1wytBm55iyBmUuxFPmZupfpReqc=";
  };

  postPatch = ''
    patchShebangs shell_scripts
    substituteInPlace shell_scripts/{awsume,awsume.fish} --replace-fail "awsumepy" "$out/bin/awsumepy"
    substituteInPlace awsume/configure/autocomplete.py --replace-fail "awsume-autocomplete" "$out/bin/awsume-autocomplete"
  '';

  nativeBuildInputs = [ installShellFiles ];
  env.AWSUME_SKIP_ALIAS_SETUP = 1;
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd awsume \
      --bash <(PYTHONPATH=./awsume/configure python3 -c"import autocomplete; print(autocomplete.SCRIPTS['bash'])") \
      --zsh <(PYTHONPATH=./awsume/configure python3 -c"import autocomplete; print(autocomplete.ZSH_AUTOCOMPLETE_FUNCTION)") \
      --fish <(PYTHONPATH=./awsume/configure python3 -c"import autocomplete; print(autocomplete.SCRIPTS['fish'])") \

    rm -f $out/bin/awsume.bat
  '';

  dependencies = with python3Packages; [
    colorama
    boto3
    psutil
    pluggy
    pyyaml
    setuptools
  ];

  format = "setuptools";

  meta = {
    description = "Utility for easily assuming AWS IAM roles from the command line";
    homepage = "https://github.com/trek10inc/awsume";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nilp0inter ];
    mainProgram = "awsume";
  };
})
