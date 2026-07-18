{
  lib,
  fetchFromGitHub,
  fluxbox,
  gitUpdater,
  gnused,
  makeWrapper,
  perlPackages,
  replaceVars,
  wrapGAppsHook3,
  xmessage,
}:

perlPackages.buildPerlPackage rec {
  pname = "fbmenugen";
  version = "0.87";

  src = fetchFromGitHub {
    owner = "trizen";
    repo = "fbmenugen";
    rev = version;
    sha256 = "A0yhoK/cPp3JlNZacgLaDhaU838PpFna7luQKNDvyOg=";
  };

  outputs = [ "out" ];

  patches = [
    (replaceVars ./0001-Fix-paths.patch {
      inherit fluxbox gnused;
      # replaced in postPatch
      fbmenugen = null;
      xmessage = xmessage;
    })
  ];

  postPatch = ''
    substituteInPlace fbmenugen --subst-var-by fbmenugen $out
  '';

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    fluxbox
    gnused
    perlPackages.DataDump
    perlPackages.FileDesktopEntry
    perlPackages.Gtk3
    perlPackages.LinuxDesktopFiles
    perlPackages.perl
    xmessage
  ];

  installPhase = ''
    runHook preInstall
    install -D -t $out/bin fbmenugen
    install -D -t $out/etc/xdg/fbmenugen schema.pl
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/fbmenugen" --prefix PERL5LIB : "$PERL5LIB"
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Simple menu generator for the Fluxbox Window Manager";
    homepage = "https://github.com/trizen/fbmenugen";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "fbmenugen";
  };
}
