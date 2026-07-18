{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "resterm";
  version = "0.44.6";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J8lvI5h3K7Ny8jkoBBLJX4qCSHkByDGWKHxDkVjAzUI=";
  };

  vendorHash = "sha256-AjckKD6NScBa8w9nWMdVExuNadz3vHnK854XXg3nj84=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.version}"
    "-X main.date=1970-01-01_00:00:00_UTC"
  ];

  # modernc.org/libc (via modernc.org/sqlite) tries to read /etc/protocols
  modPostBuild = ''
    substituteInPlace vendor/modernc.org/libc/honnef.co/go/netdb/netdb.go \
      --replace-fail '!os.IsNotExist(err)' '!os.IsNotExist(err) && !os.IsPermission(err)'
  '';

  subPackages = [ "cmd/resterm" ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based REST client";
    homepage = "https://github.com/unkn0wn-root/resterm";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "resterm";
  };
})
