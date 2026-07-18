{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "mullvad-compass";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "Ch00k";
    repo = "mullvad-compass";
    tag = finalAttrs.version;
    hash = "sha256-4Q6Pm20stbuY+KQHhIPGegCIwGiYIagduN//d+CKKXE=";
  };

  vendorHash = "sha256-gEdtoJjCa0nVyi7T4zzv6xUDTQCYFi4ANFaqXGeqcsI=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Find the best Mullvad VPN server to connect to";
    homepage = "https://github.com/Ch00k/mullvad-compass";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "mullvad-compass";
  };
})
