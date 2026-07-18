{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  coreutils,
  installShellFiles,
  nixosTests,
  pam,
  scdoc,
}:

buildGoModule (finalAttrs: {
  pname = "maddy";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "foxcpp";
    repo = "maddy";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Lt5uj7DCu6Tx47Xdzg+CjGN543LCj2x8ph+1wvD3GCQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    scdoc
  ];

  buildInputs = [ pam ];
  vendorHash = "sha256-8dMS2kFlQ762u4Ifv1O1Capr8Jb7wsQuHSsJvHwa0j0=";
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=strict-prototypes";

  postInstall = ''
    for f in docs/man/*.scd; do
      local page="docs/man/$(basename "$f" .scd)"
      scdoc < "$f" > "$page"
      installManPage "$page"
    done

    ln -s "$out/bin/maddy" "$out/bin/maddyctl"

    mkdir -p "$out/libexec/maddy"
    mv "$out/bin/maddy-pam-helper" "$out/bin/maddy-shadow-helper" "$out/libexec/maddy"

    mkdir -p $out/lib/systemd/system

    substitute dist/systemd/maddy.service $out/lib/systemd/system/maddy.service \
      --replace-fail "/usr/local/bin/maddy" "$out/bin/maddy" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"

    substitute dist/systemd/maddy@.service $out/lib/systemd/system/maddy@.service \
      --replace-fail "/usr/local/bin/maddy" "$out/bin/maddy" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/foxcpp/maddy.Version=${finalAttrs.version}"
    "-X github.com/foxcpp/maddy.DefaultLibexecDirectory=/run/wrappers/bin"
  ];

  subPackages = [
    "cmd/maddy"
    "cmd/maddy-pam-helper"
    "cmd/maddy-shadow-helper"
  ];

  tags = [ "libpam" ];
  passthru.tests.nixos = nixosTests.maddy;

  meta = {
    description = "Composable all-in-one mail server";
    homepage = "https://maddy.email";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "maddy";
  };
})
