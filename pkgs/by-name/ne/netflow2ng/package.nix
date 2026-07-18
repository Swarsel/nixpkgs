{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  pkg-config,
  versionCheckHook,
  zeromq,
}:

buildGoModule (finalAttrs: {
  pname = "netflow2ng";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "synfinatic";
    repo = "netflow2ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cBAgZhHYA9YpQ9NoiW6WNQvPi5nnZ0V3R/bbL8mNXuo=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zeromq ];
  vendorHash = "sha256-2hGY58ofzY7BTIrecdSDoo6JuQwJe4AyNPGiBpGY9lA=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/${finalAttrs.pname}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X=main.Version=${finalAttrs.version}"
    "-X=main.Buildinfos=nixpkgs"
    "-X=main.Tag=${finalAttrs.src.tag}"
    "-X=main.CommitID=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "NetFlow v9 collector for ntopng";
    homepage = "https://github.com/synfinatic/netflow2ng";
    changelog = "https://github.com/synfinatic/netflow2ng/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "netflow2ng";
  };
})
