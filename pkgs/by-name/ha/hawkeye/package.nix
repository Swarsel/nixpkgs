{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPackages,
}:

rustPackages.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hawkeye";
  version = "6.5.1";

  src = fetchFromGitHub {
    owner = "korandoru";
    repo = "hawkeye";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TBWPpfSr5ONr7HzEzPr3TbQo3fl4Szj/7cl3NafyYms=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  cargoHash = "sha256-5fUNyNYm0p44Xs4mK+nhrsUrA3LJkaO8gZrmXyRqiSo=";

  meta = {
    description = "Simple license header checker and formatter, in multiple distribution forms";
    homepage = "https://github.com/korandoru/hawkeye";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "hawkeye";
  };
})
