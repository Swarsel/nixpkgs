{
  lib,
  stdenv,
  dieHook,
  runCommand,
  testers,
}:

rec {
  copy-dll = user32-exe.overrideAttrs {
    preFixup = ''
      cp ${lib.getLib user32-dll}/bin/cygpeek.dll "$out"/bin/
      linkDLLs "$out"/bin/cygpeek.dll
    '';

    allowedImpureDLLs = [ "USER32.dll" ];
    name = "copy-dll";
  };

  copy-dll-impure = testers.testBuildFailure (
    user32-exe.overrideAttrs {
      preFixup = ''
        cp ${lib.getLib user32-dll}/bin/cygpeek.dll "$out"/bin/
      '';

      name = "copy-dll-impure";
    }
  );

  dll = stdenv.mkDerivation {
    src = ./dll;

    outputs = [
      "out"
      "dev"
    ];

    strictDeps = true;
    buildInputs = [ dll2 ];
    name = "dll";
  };

  dll2 = stdenv.mkDerivation {
    src = ./dll2;

    outputs = [
      "out"
      "dev"
    ];

    name = "dll2";
  };

  double-link = user32-exe.overrideAttrs {
    preFixup = ''linkDLLs "$out"'';
    name = "double-link";
  };

  exe = stdenv.mkDerivation {
    src = ./exe;
    strictDeps = true;
    nativeBuildInputs = [ dieHook ];
    buildInputs = [ dll ];
    doCheck = true;
    postFixup = ''[[ -e "$out"/bin/cyghello2.dll ]] || die missing indirect dependency'';
    name = "exe";
  };

  impure-dll = testers.testBuildFailure (
    user32.overrideAttrs {
      allowedImpureDLLs = [ ];
      name = "impure-dll";
    }
  );

  link-dir-dll = exe.overrideAttrs {
    preFixup = ''
      mkdir "$out"/libexec
      ln -s ${lib.getLib user32-dll}/bin/cygpeek.dll "$out"/libexec/
      linkDLLsDir="$out"/bin linkDLLs "$out"/libexec/cygpeek.dll
    '';

    name = "link-dir-dll";
  };

  link-dir-exe = exe.overrideAttrs {
    preFixup = ''
      mkdir "$out"/libexec
      ln -s ${lib.getLib user32-exe}/bin/{peek.exe,cygpeek.dll} "$out"/libexec/
      linkDLLsDir="$out"/bin linkDLLs "$out"/libexec/peek.exe
    '';

    name = "link-dir-exe";
  };

  link-dll = exe.overrideAttrs {
    preFixup = ''
      ln -s ${lib.getLib dll}/bin/cyghello.dll "$out"/bin/
    '';

    name = "link-dll";
  };

  link-user32-dll = exe.overrideAttrs {
    preFixup = ''
      ln -s ${lib.getLib user32-dll}/bin/cygpeek.dll "$out"/bin/
    '';

    name = "link-user32-dll";
  };

  user32 = stdenv.mkDerivation {
    src = ./user32;
    allowedImpureDLLs = [ "USER32.dll" ];
    name = "user32";
  };

  user32-dll = stdenv.mkDerivation {
    src = ./user32-dll;

    outputs = [
      "out"
      "dev"
    ];

    allowedImpureDLLs = [ "USER32.dll" ];
    name = "user32-dll";
  };

  user32-exe = stdenv.mkDerivation {
    src = ./user32-exe;
    strictDeps = true;
    buildInputs = [ user32-dll ];
    doCheck = true;
    name = "user32-exe";
  };

  utf8-glob = runCommand "utf8-glob" { } ''
    touch NetLock_Arany_=Class_Gold=_Főtanstvny:49412ce40010.crt
    ls -l NetLock* > "$out"
  '';
}
