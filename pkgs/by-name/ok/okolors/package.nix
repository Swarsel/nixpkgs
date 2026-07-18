{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "okolors";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "IanManske";
    repo = "Okolors";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RSkZUkwCn9uvvT2dIqM2Q4+mRqjUegVuXCms5DBugbk=";
  };

  cargoHash = "sha256-ceFyFbNmC7PoleTejymQw9Ii9rxx2qJmFifNAQjLVUM=";
  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Generate a color palette from an image using k-means clustering in the Oklab color space";
    homepage = "https://github.com/IanManske/Okolors";
    changelog = "https://github.com/IanManske/Okolors/releases/tag/v${finalAttrs.version}";

    license =
      with lib.licenses;
      OR [
        asl20
        mit
      ];

    maintainers = with lib.maintainers; [
      sandarukasa
    ];

    mainProgram = "okolors";
  };
})
