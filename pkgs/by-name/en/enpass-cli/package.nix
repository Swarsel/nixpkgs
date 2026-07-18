{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  pkg-config,
  sqlcipher,
}:

buildGoModule (finalAttrs: {
  pname = "enpass-cli";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "HazCod";
    repo = "enpass-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SloFiV+tmdjiHjeS/SsDMLZ9gjNB/EOmgexMXpu253I=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlcipher
  ];

  vendorHash = "sha256-S02hHPA7WSAMLELhfD+2cmsbhxsCiXdPbikU/GGubPc=";
  env.CGO_ENABLED = "1";

  postInstall = ''
    mv $out/bin/enpasscli $out/bin/enpass-cli
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line client for Enpass password manager";
    homepage = "https://github.com/HazCod/enpass-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ deej-io ];
    platforms = lib.platforms.unix;
    mainProgram = "enpass-cli";
  };
})
