{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "meshtastic-web";
  version = "2.6.7";

  src = fetchFromGitHub {
    owner = "meshtastic";
    repo = "web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-71/Wr/b42fknVCdeO99AI4ZpJk8Smkse/TFisKLzBCQ=";
    fetchSubmodules = true;
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  nativeBuildInputs = [
    pnpm_10
    pnpmConfigHook
    nodejs
  ];

  preConfigure = ''
    substituteInPlace packages/web/vite.config.ts \
      --replace-fail "hash = \"DEV\"" "hash = \"$(cat COMMIT)\"" \
      --replace-fail "version = \"v0.0.0\"" "version = \"${finalAttrs.version}\""
  '';

  buildPhase = ''
    runHook preBuild

    pushd packages/web
    pnpm install
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -ar dist/. $out/

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;

    fetcherVersion = 4;
    hash = "sha256-0o/g5FVzSGX9xtQ8DZGjakwOnPXvlA95tdD/VNymB1M=";
    pnpm = pnpm_10;
  };

  pnpmRoot = "packages/web";
  pnpmWorkspaces = [ "*" ];

  meta = {
    description = "Meshtastic Web Client/JS Monorepo";
    homepage = "https://github.com/meshtastic/web";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
  };
})
