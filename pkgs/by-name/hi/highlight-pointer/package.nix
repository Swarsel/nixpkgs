{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxext,
  libxfixes,
  libxi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "highlight-pointer";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "swillner";
    repo = "highlight-pointer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yCm5YpOTPWRYAzX2TRhwUnSc3LbdxjwR5Z0glUm95Cg=";
  };

  buildInputs = [
    libx11
    libxext
    libxi
    libxfixes
  ];

  installPhase = ''
    runHook preInstall

    install -m 555 -D highlight-pointer $out/bin/highlight-pointer

    runHook postInstall
  '';

  meta = {
    description = "Highlight mouse pointer/cursor using a dot";
    homepage = "https://github.com/swillner/highlight-pointer";
    changelog = "https://github.com/swillner/highlight-pointer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DCsunset ];
    platforms = lib.platforms.linux;
    mainProgram = "highlight-pointer";
  };
})
