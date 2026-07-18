{
  lib,
  stdenv,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  click,
  hatch-vcs,
  hatchling,
  installShellFiles,
  nix-update-script,
  pydantic,
  pytestCheckHook,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "philipstv";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "bcyran";
    repo = "philipstv";
    tag = version;
    hash = "sha256-AShWm9dsA9+HKuvQ7JzFjN9sn5V13MDyoxtufST4hJA=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd philipstv \
      --bash <(_PHILIPSTV_COMPLETE=bash_source $out/bin/philipstv) \
      --zsh <(_PHILIPSTV_COMPLETE=zsh_source $out/bin/philipstv) \
      --fish <(_PHILIPSTV_COMPLETE=fish_source $out/bin/philipstv)
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    requests
    pydantic
    click
    appdirs
  ];

  pyproject = true;
  pythonImportsCheck = [ "philipstv" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI and library to control Philips Android-powered TVs";
    homepage = "https://github.com/bcyran/philipstv";
    changelog = "https://github.com/bcyran/philipstv/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcyran ];
    mainProgram = "philipstv";
  };
}
