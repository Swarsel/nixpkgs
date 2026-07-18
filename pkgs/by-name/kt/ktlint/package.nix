{
  lib,
  stdenv,
  fetchurl,
  gnused,
  jre_headless,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ktlint";
  version = "1.8.0";

  src = fetchurl {
    url = "https://github.com/pinterest/ktlint/releases/download/${finalAttrs.version}/ktlint";
    sha256 = "sha256-o/1iAgfVxA2myniblef4I8VOhUt/ref2E+kQlqNwbXU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 $src $out/bin/ktlint
  '';

  postFixup = ''
    wrapProgram $out/bin/ktlint --prefix PATH : "${
      lib.makeBinPath [
        jre_headless
        gnused
      ]
    }"
  '';

  dontUnpack = true;

  meta = {
    description = "Anti-bikeshedding Kotlin linter with built-in formatter";
    homepage = "https://ktlint.github.io/";
    changelog = "https://github.com/pinterest/ktlint/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      tadfisher
      SubhrajyotiSen
    ];

    platforms = jre_headless.meta.platforms;
    mainProgram = "ktlint";
  };
})
