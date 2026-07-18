{
  lib,
  makeBinaryWrapper,
  rustPlatform,
  steel,
}:
rustPlatform.buildRustPackage {
  inherit (steel)
    version
    src
    cargoHash
    postPatch
    ;

  pname = "steel-language-server";

  nativeBuildInputs = [
    makeBinaryWrapper
    rustPlatform.bindgenHook
  ];

  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/steel-language-server --set-default STEEL_HOME "${steel}/lib/steel"
  '';

  cargoBuildFlags = [
    "--package"
    "steel-language-server"
  ];

  meta = steel.meta // {
    description = "Steel language server";
    maintainers = steel.meta.maintainers ++ [ lib.maintainers.higherorderlogic ];
    mainProgram = "steel-language-server";
  };
}
