{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash,
  binlore,
  coreutils,
  gitUpdater,
  gnugrep,
  gnused,
  gnutls,
  gsasl,
  libidn2,
  libnotify,
  libsecret,
  msmtp,
  netcat-gnu,
  pkg-config,
  resholve,
  symlinkJoin,
  systemd,
  texinfo,
  which,
  withKeyring ? true,
  withLibnotify ? true,
  withScripts ? true,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

let
  inherit (lib) getBin getExe optionals;

  version = "1.8.32";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "msmtp";
    rev = "msmtp-${version}";
    hash = "sha256-ofyDtP7KgTKX/O1O4g3OcDwgihDveAiJ5s5GQtSqf28=";
  };

  meta = {
    description = "Simple and easy to use SMTP client with excellent sendmail compatibility";
    homepage = "https://marlam.de/msmtp/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
    mainProgram = "msmtp";
  };

  binaries = stdenv.mkDerivation {
    inherit version src meta;
    pname = "msmtp-binaries";

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
      texinfo
    ];

    buildInputs = [
      gnutls
      gsasl
      libidn2
    ]
    ++ optionals withKeyring [ libsecret ];

    configureFlags = [
      "--sysconfdir=/etc"
      "--with-libgsasl"
    ]
    ++ optionals stdenv.hostPlatform.isDarwin [ "--with-macosx-keyring" ];

    postInstall = ''
      install -Dm444 -t $out/share/doc/msmtp doc/*.example
      ln -s msmtp $out/bin/sendmail
    '';

    enableParallelBuilding = true;
  };

  scripts = resholve.mkDerivation {
    inherit version src meta;
    pname = "msmtp-scripts";

    patches = [
      ./msmtpq-remove-binary-check.patch
      ./msmtpq-systemd-logging.patch
    ];

    postPatch = ''
      substituteInPlace scripts/msmtpq/msmtpq \
        --replace @journal@ ${if withSystemd then "Y" else "N"}
    '';

    installPhase = ''
      runHook preInstall

      install -Dm555 -t $out/bin                     scripts/msmtpq/msmtp*
      install -Dm444 -t $out/share/doc/msmtp/scripts scripts/msmtpq/README*
      install -Dm444 -t $out/share/doc/msmtp/scripts scripts/{find_alias,msmtpqueue,set_sendmail}/*

      if grep --quiet -E '@.+@' $out/bin/*; then
        echo "Unsubstituted variables found. Aborting!"
        grep -E '@.+@' $out/bin/*
        exit 1
      fi

      runHook postInstall
    '';

    dontBuild = true;
    dontConfigure = true;

    solutions = {
      msmtp-queue = {
        execer = [ "cannot:${placeholder "out"}/bin/msmtpq" ];
        inputs = [ "${placeholder "out"}/bin" ];
        interpreter = getExe bash;
        scripts = [ "bin/msmtp-queue" ];
      };

      msmtpq = {
        execer = [
          "cannot:${getBin binaries}/bin/msmtp"
          "cannot:${getBin netcat-gnu}/bin/nc"
        ]
        ++ optionals withSystemd [
          "cannot:${getBin systemd}/bin/systemd-cat"
        ]
        ++ optionals withLibnotify [
          "cannot:${getBin libnotify}/bin/notify-send"
        ];

        fake.external = [
          "ping"
        ]
        ++ optionals (!withSystemd) [ "systemd-cat" ]
        ++ optionals (!withLibnotify) [ "notify-send" ];

        fix."$MSMTP" = [ "msmtp" ];

        inputs = [
          binaries
          coreutils
          gnugrep
          gnused
          netcat-gnu
          which
        ]
        ++ optionals withSystemd [ systemd ]
        ++ optionals withLibnotify [ libnotify ];

        interpreter = getExe bash;
        keep.source = [ "~/.msmtpqrc" ];
        scripts = [ "bin/msmtpq" ];
      };
    };
  };

in
if withScripts then
  symlinkJoin {
    inherit version meta;
    pname = "msmtp";

    paths = [
      binaries
      scripts
    ];

    passthru = {
      inherit binaries scripts src;

      # msmtpq forwards most of its arguments to msmtp [1].
      #
      # [1]: <https://github.com/marlam/msmtp/blob/msmtp-1.8.26/scripts/msmtpq/msmtpq#L301>
      binlore.out = binlore.synthesize msmtp ''
        wrapper bin/msmtpq bin/msmtp
      '';

      updateScript = gitUpdater { rev-prefix = "msmtp-"; };
    };
  }
else
  binaries
