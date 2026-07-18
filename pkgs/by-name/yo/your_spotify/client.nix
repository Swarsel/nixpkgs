{
  stdenv,
  meta,
  nodejs,
  pnpmConfigHook,
  pnpmDeps,
  pnpm_11,
  src,
  version,
  apiEndpoint ? "http://localhost:3000",
}:

stdenv.mkDerivation {
  inherit version src pnpmDeps;
  inherit meta;
  pname = "your_spotify_client";

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_11
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pushd ./apps/client/
    pnpm run build

    export NODE_ENV=production
    substituteInPlace scripts/run/variables.sh --replace-quiet '/app/apps/client/' "./"
    chmod +x ./scripts/run/variables.sh
    patchShebangs --build ./scripts/run/variables.sh
    ./scripts/run/variables.sh
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./apps/client/build/* $out
    runHook postInstall
  '';

  API_ENDPOINT = "${apiEndpoint}";
}
