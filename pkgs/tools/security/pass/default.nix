{
  lib,
  stdenv,
  fetchurl,
  bash,
  buildEnv,
  coreutils,
  findutils,
  getopt,
  git,
  gnugrep,
  gnupg,
  gnused,
  makeWrapper,
  openssh,
  openssl,
  pass,
  pkgs,
  procps,
  qrencode,
  tree,
  which,
  dmenu ? null,
  dmenu-wayland ? null,
  dmenuSupport ? (x11Support || waylandSupport),
  # For backwards-compatibility
  tombPluginSupport ? false,
  waylandSupport ? false,
  wl-clipboard ? null,
  x11Support ? !stdenv.hostPlatform.isDarwin,
  xclip ? null,
  xdotool ? null,
  ydotool ? null,
}:

assert x11Support -> xclip != null;
assert waylandSupport -> wl-clipboard != null;

assert dmenuSupport -> x11Support || waylandSupport;
assert dmenuSupport && x11Support -> dmenu != null && xdotool != null;
assert dmenuSupport && waylandSupport -> dmenu-wayland != null && ydotool != null;

let
  passExtensions = import ./extensions { inherit pkgs; };

  env =
    extensions:
    let
      selected = [
        pass
      ]
      ++ extensions passExtensions
      ++ lib.optional tombPluginSupport passExtensions.tomb;
    in
    buildEnv {
      nativeBuildInputs = [ makeWrapper ];
      buildInputs = lib.concatMap (x: x.buildInputs) selected;

      postBuild = ''
        files=$(find $out/bin/ -type f -exec readlink -f {} \;)
        if [ -L $out/bin ]; then
          rm $out/bin
          mkdir $out/bin
        fi

        for i in $files; do
          if ! [ "$(readlink -f "$out/bin/$(basename $i)")" = "$i" ]; then
            ln -sf $i $out/bin/$(basename $i)
          fi
        done

        wrapProgram $out/bin/pass \
          --set SYSTEM_EXTENSION_DIR "$out/lib/password-store/extensions"
      '';

      name = "pass-env";
      paths = selected;
      meta.mainProgram = "pass";
    };
in

stdenv.mkDerivation rec {
  pname = "password-store";
  version = "1.7.4";

  src = fetchurl {
    url = "https://git.zx2c4.com/password-store/snapshot/${pname}-${version}.tar.xz";
    sha256 = "1h4k6w7g8pr169p5w9n6mkdhxl3pw51zphx7www6pvgjb7vgmafg";
  };

  patches = [
    ./set-correct-program-name-for-sleep.patch
    ./extension-dir.patch
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin ./no-darwin-getopt.patch;

  # Turn "check" into "installcheck", since we want to test our pass,
  # not the one before the fixup.
  postPatch = ''
    patchShebangs tests

    substituteInPlace src/password-store.sh \
      --replace "@out@" "$out"

    # the turning
    sed -i -e 's@^PASS=.*''$@PASS=$out/bin/pass@' \
           -e 's@^GPGS=.*''$@GPG=${gnupg}/bin/gpg2@' \
           -e '/which gpg/ d' \
      tests/setup.sh
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # 'pass edit' uses hdid, which is not available from the sandbox.
    rm -f tests/t0200-edit-tests.sh
    rm -f tests/t0010-generate-tests.sh
    rm -f tests/t0020-show-tests.sh
    rm -f tests/t0050-mv-tests.sh
    rm -f tests/t0100-insert-tests.sh
    rm -f tests/t0300-reencryption.sh
    rm -f tests/t0400-grep.sh
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];
  doCheck = false;

  postInstall = lib.optionalString dmenuSupport ''
    cp "contrib/dmenu/passmenu" "$out/bin/"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ git ];

  postFixup = ''
    # Fix program name in --help
    substituteInPlace $out/bin/pass \
      --replace 'PROGRAM="''${0##*/}"' "PROGRAM=pass"

    # Ensure all dependencies are in PATH
    wrapProgram $out/bin/pass \
      --prefix PATH : "${wrapperPathPrefix}" \
      --suffix PATH : "${wrapperPathSuffix}"
  ''
  + lib.optionalString dmenuSupport ''
    # We just wrap passmenu with the same PATH as pass. It doesn't
    # need all the tools in there but it doesn't hurt either.
    wrapProgram $out/bin/passmenu \
      --prefix PATH : "$out/bin:${wrapperPathPrefix}" \
      --suffix PATH : "${wrapperPathSuffix}"
  '';

  installCheckTarget = "test";

  installFlags = [
    "PREFIX=$(out)"
    "WITH_ALLCOMP=yes"
  ];

  wrapperPathPrefix = lib.makeBinPath (
    [
      coreutils
      findutils
      getopt
      gnugrep
      gnused
      tree
      which
      openssh
      procps
      qrencode
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin openssl
    ++ lib.optional x11Support xclip
    ++ lib.optional waylandSupport wl-clipboard
    ++ lib.optionals (waylandSupport && dmenuSupport) [
      ydotool
      dmenu-wayland
    ]
    ++ lib.optionals (x11Support && dmenuSupport) [
      xdotool
      dmenu
    ]
  );

  wrapperPathSuffix = lib.makeBinPath [
    git
    gnupg
  ];

  passthru = {
    extensions = passExtensions;
    withExtensions = env;
  };

  meta = {
    description = "Stores, retrieves, generates, and synchronizes passwords securely";

    longDescription = ''
      pass is a very simple password store that keeps passwords inside gpg2
      encrypted files inside a simple directory tree residing at
      ~/.password-store. The pass utility provides a series of commands for
      manipulating the password store, allowing the user to add, remove, edit,
      synchronize, generate, and manipulate passwords.
    '';

    homepage = "https://www.passwordstore.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      fpletz
      tadfisher
      globin
      ryan4yin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pass";
  };
}
