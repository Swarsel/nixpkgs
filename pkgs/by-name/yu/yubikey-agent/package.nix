{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libnotify,
  pcsclite,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "yubikey-agent";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "yubikey-agent";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Knk1ipBOzjmjrS2OFUMuxi1TkyDcSYlVKezDWT//ERY=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace main.go --replace 'notify-send' ${libnotify}/bin/notify-send
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];
  buildInputs = lib.optional stdenv.hostPlatform.isLinux (lib.getDev pcsclite);
  vendorHash = "sha256-+IRPs3wm3EvIgfQRpzcVpo2JBaFQlyY/RI1G7XfVS84=";
  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/lib/systemd/user
    substitute contrib/systemd/user/yubikey-agent.service $out/lib/systemd/user/yubikey-agent.service \
      --replace 'ExecStart=yubikey-agent' "ExecStart=$out/bin/yubikey-agent"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Seamless ssh-agent for YubiKeys";
    homepage = "https://filippo.io/yubikey-agent";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      philandstuff
      rawkode
    ];

    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "yubikey-agent";
  };
})
