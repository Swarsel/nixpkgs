{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "xc";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "joerdav";
    repo = "xc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hOwRPTH7vE8/U8UuT1z0yyRZvCGvKSX/Ncs4lFwVGVU=";
  };

  vendorHash = "sha256-EbIuktQ2rExa2DawyCamTrKRC1yXXMleRB8/pcKFY5c=";
  env.CGO_ENABLED = 0;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  postInstallCheck = ''
    cp ${./example.md} example.md
    $out/bin/xc -file ./example.md example
    if ! [[ -f test ]] then
      echo "example.md didn't do anything" >&2
      return 1
    fi
  '';

  subPackages = [ "cmd/xc" ];
  versionCheckProgramArg = "-version";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Markdown defined task runner";
    homepage = "https://xcfile.dev/";
    changelog = "https://github.com/joerdav/xc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      joerdav
    ];

    mainProgram = "xc";
  };
})
