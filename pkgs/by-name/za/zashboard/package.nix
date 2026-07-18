{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  nix-update-script,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  pname = "zashboard";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "Zephyruso";
    repo = "zashboard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GSzJpBGDCh7OPPr5OWfAAbraRjIhKkVo5/EMRmrLm/o=";
  };

  postPatch = ''
    substituteInPlace vite.config.ts \
      --replace-fail "getGitCommitId()" '""'
  '';

  nativeBuildInputs = [ pnpm ];

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;
  npmConfigHook = pnpmConfigHook;
  npmDeps = null;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-8EQziLcmP+bjQez+b0QdgF43XGydYC9yh4m9lEkbhCY=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dashboard Using Clash API";
    homepage = "https://github.com/Zephyruso/zashboard";
    changelog = "https://github.com/Zephyruso/zashboard/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chillcicada ];
  };
})
