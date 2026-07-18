{
  lib,
  fetchurl,
  jre_headless,
  makeBinaryWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ltex-ls";
  version = "16.0.0";

  src = fetchurl {
    url = "https://github.com/valentjn/ltex-ls/releases/download/${version}/ltex-ls-${version}.tar.gz";
    sha256 = "sha256-lW1TfTckqhCmhjcvduISY9qAdKPM/0cobxbIrCq5JkQ=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -rfv bin/ lib/ $out
    rm -fv $out/bin/.lsp-cli.json $out/bin/*.bat
    for file in $out/bin/{ltex-ls,ltex-cli}; do
      wrapProgram $file --set JAVA_HOME "${jre_headless}"
    done

    runHook postInstall
  '';

  meta = {
    description = "LSP language server for LanguageTool";
    homepage = "https://valentjn.github.io/ltex/";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ vinnymeller ];
    platforms = jre_headless.meta.platforms;
    mainProgram = "ltex-ls";
  };
}
