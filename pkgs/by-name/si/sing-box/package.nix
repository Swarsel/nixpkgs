{
  lib,
  fetchFromGitHub,
  buildGoModule,
  coreutils,
  installShellFiles,
  nix-update-script,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "sing-box";
  version = "1.13.14";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ODQ1i2lOuQLb3LDq6ONqHJQ7sT7dXICCJoyW/I9zF38=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-Znk4bsm9TUseEuCQszs9rvVx8TDu+cwEVfVOhw7exYA=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf
  '';

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
    "-X=internal/godebug.defaultGODEBUG=multipathtcp=0"
    "-checklinkname=0"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  tags = [
    "with_gvisor"
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "badlinkname"
    "tfogo_checklinkname0"
  ];

  passthru = {
    tests = { inherit (nixosTests) sing-box; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal proxy platform";
    homepage = "https://sing-box.sagernet.org";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      nickcao
      prince213
    ];

    mainProgram = "sing-box";
  };
})
