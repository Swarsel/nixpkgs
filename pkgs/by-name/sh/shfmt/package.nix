{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  replaceVars,
  scdoc,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "shfmt";
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "mvdan";
    repo = "sh";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NNK8fD9cmuRM1YAYagS6AEu2IOJVaoQmDX8Dm3geRQw=";
  };

  patches = [
    (replaceVars ./version.patch {
      inherit (finalAttrs) version;
    })
  ];

  nativeBuildInputs = [
    installShellFiles
    scdoc
  ];

  vendorHash = "sha256-M5EJHBE2qjlRFtc3L941qxg0KO5IbVTMpiJSJ6WNLVE=";

  postBuild = ''
    scdoc < cmd/shfmt/shfmt.1.scd > shfmt.1
    installManPage shfmt.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/shfmt" ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Shell parser and formatter";

    longDescription = ''
      shfmt formats shell programs. It can use tabs or any number of spaces to indent.
      You can feed it standard input, any number of files or any number of directories to recurse into.
    '';

    homepage = "https://github.com/mvdan/sh";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      zowoq
      SuperSandro2000
    ];

    mainProgram = "shfmt";
  };
})
