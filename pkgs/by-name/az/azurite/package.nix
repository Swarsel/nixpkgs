{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  clang_20,
  libsecret,
  nodejs-slim,
  pkg-config,
}:

buildNpmPackage (finalAttrs: {
  pname = "azurite";
  version = "3.35.0";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "Azurite";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sVYiHQJ3nR5vM+oPAHzr/MjuNBMY14afqCHpw32WCiQ=";
  };

  nativeBuildInputs = [
    pkg-config
    nodejs-slim.python
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ clang_20 ]; # clang_21 breaks @vscode/vsce's optional dependency keytar

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libsecret
  ];

  npmDepsHash = "sha256-UBHjb65Ud7IANsR30DokbI/16+dVjDEtfhqRPAQhGUw=";

  meta = {
    description = "Lightweight server clone of Azure Storage that simulates most of the commands supported by it with minimal dependencies";
    homepage = "https://github.com/Azure/Azurite";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      danielalvsaaker
    ];

    mainProgram = "azurite";
  };
})
