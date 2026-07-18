{
  lib,
  fetchzip,
  makeWrapper,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  testers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "copilot-language-server";
  version = "1.521.0";

  src = fetchzip {
    url = "https://github.com/github/copilot-language-server-release/releases/download/${finalAttrs.version}/copilot-language-server-js-${finalAttrs.version}.zip";
    hash = "sha256-uHt22/756jxh34HhIbMEu3nGebbTF1325ylWuKzZzEI=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/copilot-language-server
    cp -r ./* $out/share/copilot-language-server/

    makeWrapper ${lib.getExe nodejs} $out/bin/copilot-language-server \
      --add-flags $out/share/copilot-language-server/main.js

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Use GitHub Copilot with any editor or IDE via the Language Server Protocol";
    homepage = "https://github.com/features/copilot";

    license = {
      deprecated = false;
      free = false;
      fullName = "GitHub Copilot Product Specific Terms";
      redistributable = false;
      shortName = "GitHub Copilot License";
      url = "https://github.com/customer-terms/github-copilot-product-specific-terms";
    };

    maintainers = with lib.maintainers; [
      arunoruto
      wattmto
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "copilot-language-server";
  };
})
