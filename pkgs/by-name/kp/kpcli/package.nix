{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpcli";
  version = "4.1.3";

  src = fetchurl {
    url = "mirror://sourceforge/kpcli/kpcli-${finalAttrs.version}.pl";
    hash = "sha256-yRNj5OB/NSGoZ/aNtgLJW1PcFn5DZu5/8lQlK0F2xi8=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp ${finalAttrs.src} $out/share/kpcli.pl
    chmod +x $out/share/kpcli.pl

    makeWrapper $out/share/kpcli.pl $out/bin/kpcli --set PERL5LIB \
      "${
        with perlPackages;
        makePerlPath (
          [
            BHooksEndOfScope
            CaptureTiny
            Clipboard
            Clone
            CryptRijndael
            CryptX
            DevelGlobalDestruction
            ModuleImplementation
            ModuleRuntime
            SortNaturally
            SubExporterProgressive
            TermReadKey
            TermShellUI
            TryTiny
            FileKDBX
            FileKeePass
            PackageStash
            RefUtil
            TermReadLineGnu
            XMLParser
            boolean
            namespaceclean
          ]
          ++ lib.optional stdenv.hostPlatform.isDarwin MacPasteboard
        )
      }"
  '';

  dontUnpack = true;

  meta = {
    description = "KeePass Command Line Interface";

    longDescription = ''
      KeePass Command Line Interface (CLI) / interactive shell.
      Use this program to access and manage your KeePass 1.x or 2.x databases from a Unix-like command line.
    '';

    homepage = "http://kpcli.sourceforge.net";
    license = lib.licenses.artistic1;
    maintainers = [ lib.maintainers.j-keck ];
    platforms = lib.platforms.all;
    mainProgram = "kpcli";
  };
})
