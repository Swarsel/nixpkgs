{
  lib,
  pulumi,
  pulumi-python,
  pulumiTestHook,
  python3Packages,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  src = builtins.filterSource (name: _: !(lib.hasSuffix ".nix" name)) ./.;
  doCheck = true;

  nativeCheckInputs = [
    pulumiTestHook
    pulumi
    pulumi-python
    python3Packages.pulumi
  ];

  checkPhase = ''
    runHook preCheck
    pulumi update --skip-preview
    stackOutput=$(pulumi stack output out)
    [[ $stackOutput =~ ^[0-9a-f]{32}$ ]]
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;
  name = "pulumi-python-smoke-test";
}
