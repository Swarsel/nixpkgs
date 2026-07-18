{
  lib,
  fetchFromGitHub,
  bash,
  buildRebar3,
  config,
  coreutils,
  erlang,
  fetchHex,
  makeWrapper,
}:

let
  inherit (lib)
    assertMsg
    makeBinPath
    getVersion
    versionAtLeast
    versions
    ;

  version = "2.2.0";
  hash = "sha256-47lEUVU9Api1Yj1q+Ch8aIV8kaALhst1ty8RHTwMVcI=";

  maximumOTPVersion = "27";
  mainVersion = versions.major (getVersion erlang);
  maxAssert = versionAtLeast maximumOTPVersion mainVersion;

  proper = buildRebar3 rec {
    version = "1.4.0";

    src = fetchHex {
      inherit version;
      sha256 = "sha256-GChYQhhb0z772pfRNKXLWgiEOE2zYRn+4OPPpIhWjLs=";
      pkg = name;
    };

    name = "proper";
  };

in
if !config.allowAliases && !maxAssert then
  # Don't throw without aliases to not break CI.
  null
else
  assert assertMsg maxAssert ''
    LFE ${version} is supported on OTP <=${maximumOTPVersion}, not ${mainVersion}.
  '';
  buildRebar3 {
    inherit version;

    src = fetchFromGitHub {
      inherit hash;
      owner = "lfe";
      repo = "lfe";
      tag = "v${version}";
    };

    patches = [
      ./fix-rebar-config.patch
      ./dedup-ebins.patch
    ];

    nativeBuildInputs = [
      makeWrapper
      erlang
    ];

    doCheck = true;

    # override buildRebar3's install to let the builder use make install
    installPhase = ''
      runHook preInstall
      make -e MANDB= PREFIX=$out install
      runHook postInstall
    '';

    doInstallCheck = true;

    installCheckPhase = ''
      runHook preInstallCheck
      test -e $out/bin/lfe
      runHook postInstallCheck
    '';

    postFixup = ''
      # LFE binaries are shell scripts which run erl and lfe.
      # Add some stuff to PATH so the scripts can run without problems.
      for f in $out/bin/*; do
        wrapProgram $f \
          --prefix PATH ":" "${
            makeBinPath [
              erlang
              coreutils
              bash
            ]
          }:$out/bin"
        substituteInPlace $f --replace "/usr/bin/env" "${coreutils}/bin/env"
      done
    '';

    beamDeps = [ proper ];
    checkTarget = "travis";
    name = "lfe";

    meta = {
      description = "Best of Erlang and of Lisp; at the same time";

      longDescription = ''
        LFE, Lisp Flavoured Erlang, is a lisp syntax front-end to the Erlang
        compiler. Code produced with it is compatible with "normal" Erlang
        code. An LFE evaluator and shell is also included.
      '';

      homepage = "https://lfe.io";
      changelog = "https://github.com/lfe/lfe/releases/tag/v${version}";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
      downloadPage = "https://github.com/lfe/lfe/releases";
      teams = [ lib.teams.beam ];
    };
  }
