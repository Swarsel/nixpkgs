{
  lib,
  fetchFromGitHub,
  buildGoModule,
  bun,
  makeWrapper,
  nodejs,
  prettier,
}:

buildGoModule (finalAttrs: {
  pname = "jxscout";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "francisconeves97";
    repo = "jxscout";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jAtij9VJFYISXibmes+oO/Hh1MoEThkqfzmBe+z1RqQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = null;
  doCheck = true;

  postInstall = ''
    wrapProgram $out/bin/jxscout --prefix PATH : ${
      lib.makeBinPath [
        prettier
        bun
        nodejs
      ]
    }
  '';

  subPackages = [ "cmd/jxscout" ];

  meta = {
    description = "jxscout superpowers JavaScript analysis for security researchers (free version)";
    homepage = "https://jxscout.app/";
    changelog = "https://github.com/francisconeves97/jxscout/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ katok ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin ++ lib.platforms.windows;
    mainProgram = "jxscout";
    downloadPage = "https://github.com/francisconeves97/jxscout";
  };
})
