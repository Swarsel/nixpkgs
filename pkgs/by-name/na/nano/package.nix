{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  callPackage,
  common-updater-scripts,
  coreutils,
  gitMinimal,
  gnused,
  ncurses,
  nix,
  texinfo,
  writeScript,
  enableNls ? true,
  enableTiny ? false,
  file ? null,
  gettext ? null,
}:

assert enableNls -> (gettext != null);

let
  nixSyntaxHighlight = fetchFromGitHub {
    hash = "sha256-S9p/g8DZhZ1cZdyFI6eaOxxGAbz+dloFEWdamAHo120=";
    owner = "seitz";
    repo = "nanonix";
    rev = "5c30e1de6d664d609ff3828a8877fba3e06ca336";
  };

in
stdenv.mkDerivation rec {
  pname = "nano";
  version = "9.1";

  src = fetchurl {
    url = "mirror://gnu/nano/nano-${version}.tar.xz";
    hash = "sha256-X0d2QnTLdTI0nOCqIOwQ8ejoUabp+j62aBLEPRltsEI=";
  };

  outputs = [
    "out"
    "doc"
    "info"
    "man"
  ];

  strictDeps = true;
  nativeBuildInputs = [ texinfo ] ++ lib.optional enableNls gettext;
  buildInputs = [ ncurses ] ++ lib.optional (!enableTiny) file;

  configureFlags = [
    "--sysconfdir=/etc"
    (lib.enableFeature enableNls "nls")
    (lib.enableFeature enableTiny "tiny")
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "gl_cv_func_strcasecmp_works=yes"
  ];

  postInstall =
    if enableTiny then
      null
    else
      ''
        cp ${nixSyntaxHighlight}/nix.nanorc $out/share/nano/
      '';

  enableParallelBuilding = true;
  # https://hydra.nixos.org/build/300187289/nixlog/1
  # openat-die.c:57:10: error: format string is not a string literal (potentially insecure) [-Werror,-Wformat-security]
  hardeningDisable = [ "format" ];

  passthru = {
    tests = {
      expect = callPackage ./test-with-expect.nix { };
    };

    updateScript = writeScript "update.sh" ''
      #!${stdenv.shell}
      set -o errexit
      PATH=${
        lib.makeBinPath [
          common-updater-scripts
          gitMinimal
          nix
          coreutils
          gnused
        ]
      }

      oldVersion="$(nix-instantiate --eval -E "with import ./. {}; lib.getVersion ${pname}" | tr -d '"')"
      latestTag="$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags git://git.savannah.gnu.org/nano.git '*' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed 's|^v||g')"

      if [ ! "$oldVersion" = "$latestTag" ]; then
        update-source-version ${pname} "$latestTag" --version-key=version --print-changes
      else
        echo "${pname} is already up-to-date"
      fi
    '';
  };

  meta = {
    description = "Small, user-friendly console text editor";
    homepage = "https://www.nano-editor.org/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      sigmasquadron
    ];

    platforms = lib.platforms.all;
    mainProgram = "nano";
  };
}
