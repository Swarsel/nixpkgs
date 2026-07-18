{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "copykitten";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Klavionik";
    repo = "copykitten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hjkRVX2+CuLyQw8/1cHRf84qbxPxAnDxCm5gVwdhecs=";
  };

  # The tests get/set the contents of the clipboard by running subprocesses.
  # On Darwin, the tests try to use `pbcopy`/`pbpaste`, which aren't packaged in Nix.
  # On Linux, I tried adding `xclip` to `nativeCheckInputs`, but got errors about
  # displays being null and the clipboard never being initialized.
  doCheck = false;

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-Ujed/3vckHMkYaQ1Euj+KaPG4yeERS7HBbl5SzvbOWE=";
  };

  dependencies = [
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "copykitten" ];

  meta = {
    description = "Robust, dependency-free way to use the system clipboard in Python";
    homepage = "https://github.com/Klavionik/copykitten";
    changelog = "https://github.com/Klavionik/copykitten/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.samasaur ];
    platforms = lib.platforms.all;
  };
})
