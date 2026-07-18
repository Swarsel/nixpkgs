{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tarmac";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "Roblox";
    repo = "tarmac";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WBkdC5YzZPtqQ9khxmvSFBHhZzfjICWkFcdi1PNsj5g=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-u6EQLCdANSi1TBy2O1P5Ro5gJlfBjh/Xm7/uzCHtRu0=";

  meta = {
    description = "Resource compiler and asset manager for Roblox";

    longDescription = ''
      Tarmac is a resource compiler and asset manager for Roblox projects.
      It helps enable hermetic place builds when used with tools like Rojo.
    '';

    homepage = "https://github.com/Roblox/tarmac";
    changelog = "https://github.com/Roblox/tarmac/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tarmac";
    downloadPage = "https://github.com/Roblox/tarmac/releases/tag/v${finalAttrs.version}";
  };
})
