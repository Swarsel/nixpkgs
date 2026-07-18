{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  nix-update-script,
  pnpmConfigHook,
  pnpm_11,
}:

let
  pnpm = pnpm_11;
in
buildNpmPackage (finalAttrs: {
  pname = "nezha-theme-user";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "hamster1963";
    repo = "nezha-dash-v2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ikrRkYrJnTRaBk3u6Ju0csRW9K3Udydh/JFTi/GxVOs=";
  };

  postPatch = ''
    # We cannot directly get the git commit hash from the tarball
    substituteInPlace vite.config.ts \
      --replace-fail 'git rev-parse --short HEAD' 'echo ${finalAttrs.src.rev}'
    substituteInPlace src/components/Footer.tsx \
      --replace-fail '/commit/' '/tree/'
  '';

  nativeBuildInputs = [ pnpm ];

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  dontNpmInstall = true;
  npmConfigHook = pnpmConfigHook;
  npmDeps = null;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-5lzMFY+PYHSQTWSewfLaspgeRq5PwWnU0ZzHYPzSMwE=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nezha monitoring user frontend based on next.js";
    homepage = "https://github.com/hamster1963/nezha-dash-v2";
    changelog = "https://github.com/hamster1963/nezha-dash-v2/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
