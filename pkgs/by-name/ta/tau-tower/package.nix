{
  lib,
  fetchFromGitHub,
  nix-update-script,
  perl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tau-tower";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vbUR2ZfnomUkWdz2xdFReR6B0lzz4dKM88RonAWu994=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  cargoHash = "sha256-Qv97FTiccfQSBI2OBfl31p3oF/JCL/+UXkK+owuByDY=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Webradio server - broadcasts audio source to clients";
    homepage = "https://github.com/tau-org/tau-tower";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "tau-tower";
    teams = with lib.teams; [ ngi ];
  };
})
