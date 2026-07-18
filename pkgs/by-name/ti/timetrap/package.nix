{
  lib,
  stdenv,
  bundlerApp,
  bundlerEnv,
  bundlerUpdateScript,
  installShellFiles,
  ruby_3_4,
}:

let
  pname = "timetrap";

  ttBundlerApp = (bundlerApp.override { ruby = ruby_3_4; }) {
    inherit pname;

    exes = [
      "t"
      "timetrap"
    ];

    gemdir = ./.;
    passthru.updateScript = bundlerUpdateScript "timetrap";
  };

  ttGem = (bundlerEnv.override { ruby = ruby_3_4; }) {
    inherit pname;
    gemdir = ./.;
  };

in

stdenv.mkDerivation {
  inherit pname;
  inherit (ttBundlerApp) version;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir $out
    cd $out

    mkdir bin; pushd bin
    ln -vs ${ttBundlerApp}/bin/t
    ln -vs ${ttBundlerApp}/bin/timetrap
    popd

    for c in t timetrap; do
      installShellCompletion --cmd $c --bash ${ttGem}/lib/ruby/gems/*/gems/timetrap*/completions/bash/*
      installShellCompletion --cmd $c --zsh ${ttGem}/lib/ruby/gems/*/gems/timetrap*/completions/zsh/*
    done
  '';

  dontUnpack = true;

  passthru = {
    updateScript = ttBundlerApp.passthru.updateScript;
  };

  meta = {
    description = "Simple command line time tracker written in ruby";
    homepage = "https://github.com/samg/timetrap";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jerith666
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
