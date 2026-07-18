{
  lib,
  fetchFromGitHub,
  buildGo125Module,
  makeWrapper,
  runCommand,
  symlinkJoin,
  tflint,
  tflint-plugins,
  versionCheckHook,
}:

buildGo125Module (finalAttrs: {
  pname = "tflint";
  version = "0.61.0";

  src = fetchFromGitHub {
    owner = "terraform-linters";
    repo = "tflint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j2bP3McVCxtVEVQYs3mHWFtmUTKDIEd5aU4I/6W/Pns=";
  };

  vendorHash = "sha256-R4NmHSyay0FGpOSMNPbXWxNJFH3lhyWxGeJsNefkBrc=";
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  passthru.withPlugins =
    plugins:
    let
      actualPlugins = plugins tflint-plugins;
      pluginDir = symlinkJoin {
        name = "tflint-plugin-dir";
        paths = [ actualPlugins ];
      };
    in
    runCommand "tflint-with-plugins-${finalAttrs.version}"
      {
        inherit (finalAttrs) version;
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper ${tflint}/bin/tflint $out/bin/tflint \
          --set TFLINT_PLUGIN_DIR "${pluginDir}"
      '';

  meta = {
    description = "Terraform linter focused on possible errors, best practices, and so on";
    homepage = "https://github.com/terraform-linters/tflint";
    changelog = "https://github.com/terraform-linters/tflint/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "tflint";
  };
})
