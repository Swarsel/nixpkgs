{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  installShellFiles,
  nix-update-script,
  scdoc,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "senpai";
  version = "0.5.0";

  src = fetchFromSourcehut {
    owner = "~delthas";
    repo = "senpai";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VjXgKdy4IpBhAP6uw/NtlexPki7nJzQi/HuY/+5lE/o=";
  };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  vendorHash = "sha256-4Ax9YVa9z1Unk3Z2iy9ZEqKjNmdgK0aF4GrD9ucXtjk=";

  postInstall = ''
    scdoc < doc/senpai.1.scd > doc/senpai.1
    scdoc < doc/senpai.5.scd > doc/senpai.5
    installManPage doc/senpai.*
    install -D -m 444 -t $out/share/applications contrib/senpai.desktop
    install -D -m 444 res/icon.48.png $out/share/icons/hicolor/48x48/apps/senpai.png
    install -D -m 444 res/icon.128.png $out/share/icons/hicolor/128x128/apps/senpai.png
    install -D -m 444 res/icon.svg $out/share/icons/hicolor/scalable/apps/senpai.svg
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X git.sr.ht/~delthas/senpai.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/senpai"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Your everyday IRC student";
    homepage = "https://sr.ht/~delthas/senpai/";
    changelog = "https://git.sr.ht/~delthas/senpai/refs/v${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ malte-v ];
    mainProgram = "senpai";
  };
})
