{
  stdenv,
  fetchPnpmDeps,
  moonfire-nvr,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (moonfire-nvr) version src;
  pname = "moonfire-nvr-ui";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  installPhase = ''
    runHook preInstall

    cp -r public $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-U/SHOVlx0kj1hfl09KcPg3CQZX9HZE5SghVEThWL1RA=";
    pnpm = pnpm_10;
    sourceRoot = "${finalAttrs.src.name}/ui";
  };

  sourceRoot = "${finalAttrs.src.name}/ui";

  meta = moonfire-nvr.meta // {
    description = "Moonfire UI";
  };
})
