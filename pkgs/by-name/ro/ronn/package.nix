{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  callPackage,
  groff,
  makeWrapper,
}:
let
  rubyEnv = bundlerEnv {
    gemdir = ./.;
    name = "ronn-gems";
  };
in
stdenv.mkDerivation {
  pname = "ronn";
  version = rubyEnv.gems.ronn-ng.version;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${rubyEnv}/bin/ronn $out/bin/ronn \
      --set PATH ${groff}/bin

    runHook postInstall
  '';

  dontUnpack = true;
  passthru.tests.reproducible-html-manpage = callPackage ./test-reproducible-html.nix { };
  passthru.updateScript = bundlerUpdateScript "ronn";

  meta = {
    description = "Markdown-based tool for building manpages";
    homepage = "https://github.com/apjanke/ronn-ng";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zimbatm
      nicknovitski
    ];

    platforms = rubyEnv.ruby.meta.platforms;
    mainProgram = "ronn";
  };
}
