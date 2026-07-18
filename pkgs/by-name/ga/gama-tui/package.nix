{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gama-tui";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "termkit";
    repo = "gama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ISgORjzH7ZigQYm7PSA4ZClhpw2GU7yor580fEf5UNc=";
  };

  vendorHash = "sha256-PTyrSXLMr244+ZTvjBBUc1gmwYXBAs0bXZS2t3aSWFQ=";
  # requires network access
  doCheck = false;

  ldflags = [
    "-s"
    "-X main.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Manage your GitHub Actions from Terminal with great UI";
    homepage = "https://github.com/termkit/gama";
    changelog = "https://github.com/termkit/gama/releases";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "gama";
  };
})
