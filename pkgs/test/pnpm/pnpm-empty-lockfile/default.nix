{
  stdenv,
  fetchPnpmDeps,
  nodejs,
  pkgs,
  pnpmConfigHook,
  pnpm_10,
}:
stdenv.mkDerivation {
  src = ./.;

  nativeBuildInputs = [
    pnpm_10
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild
    touch $out
    runHook postBuild
  '';

  name = "pnpm-empty-lockfile";

  pnpmDeps = fetchPnpmDeps {
    pname = "pnpm-empty-lockfile";
    src = ./.;
    fetcherVersion = 3;
    hash = "sha256-u0GOAX5B1f2ANWbOezScp/eKQRRZA/JoYfQ5zLrNip4=";
    pnpm = pnpm_10;
  };
}
