{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  buildPythonPackage,
  installShellFiles,
  pygments,
  pytestCheckHook,
  ruamel-yaml,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "jc";
  version = "1.25.7";

  src = fetchFromGitHub {
    owner = "kellyjonbrazil";
    repo = "jc";
    tag = "v${version}";
    hash = "sha256-aufAR+Y5ocJNWSr8CLIb0TZM6a3B6jqS3Ji1WIOLzBU=";
  };

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [
    ruamel-yaml
    xmltodict
    pygments
  ];

  # tests require timezone to set America/Los_Angeles
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd jc \
        --bash <(${emulator} $out/bin/jc --bash-comp) \
        --zsh  <(${emulator} $out/bin/jc --zsh-comp)
    '';

  format = "setuptools";
  pythonImportsCheck = [ "jc" ];

  meta = {
    description = "This tool serializes the output of popular command line tools and filetypes to structured JSON output";
    homepage = "https://github.com/kellyjonbrazil/jc";
    changelog = "https://github.com/kellyjonbrazil/jc/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ atemu ];
    mainProgram = "jc";
  };
}
