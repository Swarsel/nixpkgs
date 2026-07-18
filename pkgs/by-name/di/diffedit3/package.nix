{
  lib,
  diffedit3,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "diffedit3";
  version = "0.6.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-tlrP97XMAAnk5H5wTHPsP1DMSmDqV9wJp1n+22jUtnM=";
  };

  cargoHash = "sha256-Hv3T0pxNUwp7No5tmFopMGjNdxfje4gRODj3B7sDVcg=";

  passthru = {
    tests = testers.testVersion {
      package = diffedit3;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "3-pane diff editor";
    homepage = "https://github.com/ilyagr/diffedit3";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ thoughtpolice ];
    mainProgram = "diffedit3";
  };
})
