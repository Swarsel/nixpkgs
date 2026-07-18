{
  lib,
  fetchFromGitHub,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clipaste";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "hqhq1025";
    repo = "clipaste";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MNrhOvdyYs99Z6Wwf2X+xCNRzc6erpLpFB/GHBJRhrg=";
  };

  strictDeps = true;
  cargoHash = "sha256-QrUR3xHZ/1FFkBYt5qxi0mNVTvEaWBcLSjp6OnzR9GY=";
  __structuredAttrs = true;

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Screenshot clipboard paste fix for AI agents";
    homepage = "https://github.com/hqhq1025/clipaste";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.darwin;
    mainProgram = "clipaste";
  };
})
