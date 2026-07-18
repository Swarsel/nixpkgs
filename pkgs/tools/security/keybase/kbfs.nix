{
  lib,
  buildGoModule,
  keybase,
}:

buildGoModule {
  inherit (keybase) src version vendorHash;
  pname = "kbfs";

  ldflags = [
    "-s"
    "-w"
  ];

  modRoot = "go";

  subPackages = [
    "kbfs/kbfsfuse"
    "kbfs/redirector"
    "kbfs/kbfsgit/git-remote-keybase"
  ];

  tags = [ "production" ];

  meta = {
    description = "Keybase filesystem";
    homepage = "https://keybase.io/docs/kbfs";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      avaq
      rvolosatovs
      bennofs
      np
      shofius
    ];
  };
}
