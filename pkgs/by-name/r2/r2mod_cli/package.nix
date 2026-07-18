{
  lib,
  stdenv,
  bashInteractive,
  fetchzip,
  jq,
  makeWrapper,
  p7zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "r2mod_cli";
  version = "1.3.3";

  src = fetchzip {
    url = "https://thunderstore.io/package/download/Foldex/r2mod_cli/${finalAttrs.version}/";
    hash = "sha256-J7ybNZa44/H+AjQ7L949I3iClXoDwinl/ITMK/QsTR0=";
    extension = "zip";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bashInteractive ];

  makeFlags = [
    "DESTDIR="
    "PREFIX=$(out)"
  ];

  postInstall = ''
    wrapProgram $out/bin/r2mod --prefix PATH : "${
      lib.makeBinPath [
        jq
        p7zip
      ]
    }";
  '';

  meta = {
    description = "Risk of Rain 2 Mod Manager in Bash";
    homepage = "https://thunderstore.io/package/Foldex/r2mod_cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.reedrw ];
    platforms = lib.platforms.unix;
    mainProgram = "r2mod";
  };
})
