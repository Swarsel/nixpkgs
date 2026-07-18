{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  d2,
  git,
  installShellFiles,
  libdrm,
  libgbm,
  makeWrapper,
  playwright-driver,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "d2";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "terrastruct";
    repo = "d2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZRAvMcJKQmvcBbT2foKDYS0gTeqOZqFu3V3iXIbfLsQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = lib.optionals (lib.meta.availableOn stdenv.hostPlatform libdrm) [
    libgbm
    playwright-driver.browsers
  ];

  vendorHash = "sha256-UZDk2upJ0xTSAg/DpRHCzdAOLnaeI0WLMJ6jNt8elKI=";
  nativeCheckInputs = [ git ];

  preCheck = ''
    # See https://github.com/terrastruct/d2/blob/master/docs/CONTRIBUTING.md#running-tests.
    export TESTDATA_ACCEPT=1
  '';

  postInstall = ''
    installManPage ci/release/template/man/d2.1
  ''
  # Wrap the d2 executable to set LD_LIBRARY_PATH for Playwright
  + lib.optionalString (finalAttrs.buildInputs != [ ]) ''
    wrapProgram $out/bin/d2 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs}
  '';

  excludedPackages = [ "./e2etests" ];

  ldflags = [
    "-s"
    "-w"
    "-X oss.terrastruct.com/d2/lib/version.Version=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = d2;
  };

  meta = {
    description = "Modern diagram scripting language that turns text to diagrams";
    homepage = "https://d2lang.com";
    changelog = "https://github.com/terrastruct/d2/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    mainProgram = "d2";
  };
})
