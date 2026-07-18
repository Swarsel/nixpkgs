{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  lz4,
  nodejs,
  npmHooks,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "coroot";
  version = "1.23.3";

  src = fetchFromGitHub {
    owner = "coroot";
    repo = "coroot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-93WJv11NDk2/ScmdE4D2E8JmyBlP4FYuX7j4Jbm8bDE=";
  };

  nativeBuildInputs = [
    pkg-config
    nodejs
    npmHooks.npmConfigHook
  ];

  buildInputs = [ lz4 ];
  vendorHash = "sha256-npMQah59pJqF6wgD2dlEleneIZbP/atDGEpjjb+KCpI=";

  preBuild = ''
    npm --prefix="$npmRoot" run build-prod
  '';

  # required for tests
  __darwinAllowLocalNetworking = true;

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/front";
    hash = "sha256-5N4dmtKdZgwulqxFHYKhnHOYAg0gnb/rzVVcmzjYFUg=";
  };

  npmRoot = "front";

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    preBuild = null;
  };

  meta = {
    description = "Open-source APM & Observability tool";
    homepage = "https://coroot.com";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ errnoh ];
    mainProgram = "coroot";
  };
})
