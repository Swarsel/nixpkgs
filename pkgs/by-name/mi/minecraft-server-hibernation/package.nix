{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "minecraft-server-hibernation";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "gekware";
    repo = "minecraft-server-hibernation";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VLn/33g/y1blDIjBjriXvkRwK056ILftiB/dwoargFY=";
  };

  vendorHash = null;

  checkFlags =
    let
      skippedTests = [
        # Disable tests requiring network access
        "Test_getPing"
        "Test_getReqType"
        "Test_QueryBasic"
        "Test_QueryFull"
      ];
    in
    [
      "-skip"
      "${builtins.concatStringsSep "|" skippedTests}"
    ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Autostart and stop minecraft-server when players join/leave";
    homepage = "https://github.com/gekware/minecraft-server-hibernation";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ squarepear ];
    mainProgram = "msh";
  };
})
