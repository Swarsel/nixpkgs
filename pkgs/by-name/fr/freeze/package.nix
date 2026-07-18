{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "freeze";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "optiv";
    repo = "Freeze";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BE5MvCU+NfEccauOdWNty/FwMiWwLttPh7eE9+UzEMY=";
  };

  vendorHash = "sha256-R8kdFweMhAUjJ8zJ7HdF5+/vllbNmARdhU4hOw4etZo=";

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mv $out/bin/Freeze $out/bin/freeze
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Payload toolkit for bypassing EDRs";
    homepage = "https://github.com/optiv/Freeze";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "freeze";
  };
})
