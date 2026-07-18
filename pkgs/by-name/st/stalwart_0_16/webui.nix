{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  gnutar,
  nix-update-script,
  stalwart_0_16,
}:
buildNpmPackage (finalAttrs: {
  pname = "webui";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "webui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V1g5lzkmO2NadRETwmp7ijEuzG3n83uO+6O1wdlF8G8=";
  };

  nativeBuildInputs = [ gnutar ];
  npmDepsHash = "sha256-XusIkv2lSwO/FXy+QsLAtcrSwN28SUa07/kj39Mr+u0=";

  env = {
    # https://github.com/stalwartlabs/webui/tree/main#environment-variables
    # https://github.com/stalwartlabs/webui/blob/main/.env.development
    VITE_API_BASE_URL = "";
    VITE_OAUTH_CLIENT_ID = "stalwart-webui";
  };

  preBuild = ''
    rm .env.development
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    npm run test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    tar -czvf $out/webui.tar.gz dist
    runHook postInstall
  '';

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    inherit (stalwart_0_16.meta) maintainers;
    description = "Stalwart WebUI";

    longDescription = ''
      Stalwart WebUI is schema-driven single-page application for administering Stalwart.

      After authentication the panel fetches a JSON schema from the server and dynamically
      generates all forms, lists, navigation, and layouts from that schema. Nothing is hardcoded.
    '';

    homepage = "https://github.com/stalwartlabs/webui";
    changelog = "https://github.com/stalwartlabs/webui/blob/${finalAttrs.src.tag}/CHANGELOG.md";

    license = lib.licenses.OR [
      lib.licenses.agpl3Only
      {
        free = false;
        fullName = "Stalwart Enterprise License 2.0 (SELv2) Agreement";
        redistributable = false;
        url = "https://github.com/stalwartlabs/webui/blob/main/LICENSES/LicenseRef-SEL.txt";
      }
    ];
  };
})
