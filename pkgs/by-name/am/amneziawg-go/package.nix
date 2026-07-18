{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "amneziawg-go";
  version = "0.2.19";

  src = fetchFromGitHub {
    owner = "amnezia-vpn";
    repo = "amneziawg-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Uy/zsdmNpcOpohwewPbSNBOzLpyV+zoTdZJJm7XxKI=";
  };

  postPatch = ''
    # Skip formatting tests
    rm -f format_test.go
  '';

  strictDeps = true;
  vendorHash = "sha256-oqnDK3H+ssgAc1F85OS/qfJRE+LCnfxDy3v7bf4RxUQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Userspace Go implementation of AmneziaWG";
    homepage = "https://github.com/amnezia-vpn/amneziawg-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ averyanalex ];
    mainProgram = "amneziawg-go";
  };
})
