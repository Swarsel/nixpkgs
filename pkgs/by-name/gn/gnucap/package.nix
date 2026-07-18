{
  lib,
  stdenv,
  callPackage,
  fetchgit,
  installShellFiles,
  readline,
  runCommand,
  termcap,
  writeScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnucap";
  version = "20240220";

  src = fetchgit {
    url = "https://https.git.savannah.gnu.org/git/gnucap.git";
    tag = finalAttrs.version;
    hash = "sha256-aZMiNKwI6eQZAxlF/+GoJhKczohgGwZ0/Wgpv3+AhYY=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    readline
    termcap
  ];

  doCheck = true;

  postInstall = ''
    installManPage man/*
  '';

  passthru = {
    plugins = callPackage ./plugins.nix { };

    tests = {
      verilog = runCommand "gnucap-verilog-test" { } ''
        echo "attach mgsim" | ${
          finalAttrs.finalPackage.withPlugins (p: [ p.verilog ])
        }/bin/gnucap -a msgsim > $out
        cat $out | grep "verilog: already installed"
      '';
    };

    withPlugins =
      p:
      let
        gnucap = finalAttrs.finalPackage;
        selectedPlugins = p gnucap.plugins;
        wrapper = writeScript "gnucap" ''
          export GNUCAP_PLUGPATH=${gnucap}/lib/gnucap
          for plugin in ${builtins.concatStringsSep " " selectedPlugins}; do
            export GNUCAP_PLUGPATH=$plugin/lib/gnucap:$GNUCAP_PLUGPATH
          done
          ${lib.getExe gnucap}
        '';
      in
      stdenv.mkDerivation {
        inherit (finalAttrs) version;
        inherit (finalAttrs) meta;
        pname = "${finalAttrs.pname}-with-plugins";
        propagatedBuildInputs = selectedPlugins;

        installPhase = ''
          mkdir -p $out/bin
          cp ${wrapper} $out/bin/gnucap
        '';

        dontUnpack = true;
      };
  };

  meta = {
    description = "Gnu Circuit Analysis Package";

    longDescription = ''
      Gnucap is a modern general purpose circuit simulator with several advantages over Spice derivatives.
      It performs nonlinear dc and transient analyses, fourier analysis, and ac analysis.
    '';

    homepage = "http://www.gnucap.org/";
    changelog = "https://gitweb.git.savannah.gnu.org/gitweb/?p=gnucap.git;a=blob;f=NEWS";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.raboof ];
    platforms = lib.platforms.all;
    mainProgram = "gnucap";
    broken = stdenv.hostPlatform.isDarwin; # Relies on LD_LIBRARY_PATH
  };
})
