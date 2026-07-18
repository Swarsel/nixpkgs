{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  coreutils,
  esh,
  gawk,
  git,
  gnupg,
  gnutar,
  installShellFiles,
  /*
    TODO: yadm can use git-crypt and transcrypt
    but it does so in a way that resholve 0.6.0
    can't yet do anything smart about. It looks
    like these are for interactive use, so the
    main impact should just be that users still
    need both of these packages in their profile
    to support their use in yadm.
  */
  # git-crypt,
  # transcrypt,
  j2cli,
  openssl,
  resholve,
  runCommand,
  yadm,
  # Templates:
  withAwk ? true,
  withEsh ? true,
  # Encryption:
  withGpg ? true,
  withJ2 ? true,
  withOpenssl ? true,
}:
let
  withTar = withGpg || withOpenssl;
in
resholve.mkDerivation (finalAttrs: {
  pname = "yadm";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "yadm-dev";
    repo = "yadm";
    rev = finalAttrs.version;
    hash = "sha256-hDo6zs70apNhKmuvR+eD51FzuTLj3SL/wHQXqLMD9QE=";
  };

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin yadm
    runHook postInstall
  '';

  postInstall = ''
    installManPage yadm.1
    installShellCompletion --cmd yadm \
      --zsh completion/zsh/_yadm \
      --bash completion/bash/yadm
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;

  solutions = {
    yadm = {
      /*
        TODO: these should be dropped as fast as they can be dealt
              with properly in binlore and/or resholve.
      */
      execer = [
        "cannot:${j2cli}/bin/j2"
        "cannot:${esh}/bin/esh"
        "cannot:${git}/bin/git"
        "cannot:${gnupg}/bin/gpg"
      ];

      fake = {
        external = lib.optional (!stdenv.hostPlatform.isCygwin) "cygpath" ++ lib.optional (!withTar) "tar";
      };

      fix = {
        "$AWK_PROGRAM" = lib.optional withAwk "awk";
        "$ESH_PROGRAM" = lib.optional withEsh "esh";
        "$GIT_PROGRAM" = [ "git" ];
        "$GPG_PROGRAM" = lib.optional withGpg "gpg";
        # see head comment
        # "$GIT_CRYPT_PROGRAM" = [ "git-crypt" ];
        # "$TRANSCRYPT_PROGRAM" = [ "transcrypt" ];
        "$J2CLI_PROGRAM" = lib.optional withJ2 "j2";
        "$OPENSSL_PROGRAM" = lib.optional withOpenssl "openssl";
        # not in nixpkgs (yet)
        # "$ENVTPL_PROGRAM" = [ "envtpl" ];
        # "$LSB_RELEASE_PROGRAM" = [ "lsb_release" ];
      };

      inputs = [
        bash
        coreutils
        git
        # see head comment
        # git-crypt
        # transcrypt
      ]
      ++ lib.optional withGpg gnupg
      ++ lib.optional withOpenssl openssl
      ++ lib.optional withAwk gawk
      ++ lib.optional withJ2 j2cli
      ++ lib.optional withEsh esh
      ++ lib.optional withTar gnutar;

      interpreter = "${bash}/bin/sh";

      keep = {
        "$AWK_PROGRAM" = !withAwk;
        # not in nixpkgs
        "$ENVTPL_PROGRAM" = true;
        "$ESH_PROGRAM" = !withEsh;
        "$GPG_PROGRAM" = !withGpg;
        "$J2CLI_PROGRAM" = !withJ2;
        "$LSB_RELEASE_PROGRAM" = true;
        "$OPENSSL_PROGRAM" = !withOpenssl;
        "$SHELL" = true; # probably user env? unsure
        "$YADM_COMMAND" = true; # internal cmds
        "$hook_command" = true; # ~git hooks?
        "$log" = true; # dynamic level-specific loggers
        "$processor" = true; # dynamic, template-engine
        "exec" = [ "$YADM_BOOTSTRAP" ]; # yadm bootstrap script
      };

      scripts = [ "bin/yadm" ];
    };
  };

  passthru.tests = {
    minimal = runCommand "${finalAttrs.pname}-test" { } ''
      export HOME=$out
      ${yadm}/bin/yadm init
    '';
  };

  meta = {
    description = "Yet Another Dotfiles Manager";

    longDescription = ''
      yadm is a dotfile management tool with 3 main features:
      * Manages files across systems using a single Git repository.
      * Provides a way to use alternate files on a specific OS or host.
      * Supplies a method of encrypting confidential data so it can safely be stored in your repository.
    '';

    homepage = "https://github.com/yadm-dev/yadm";
    changelog = "https://github.com/yadm-dev/yadm/blob/${finalAttrs.version}/CHANGES";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      abathur
      sandarukasa
    ];

    platforms = lib.platforms.unix;
    mainProgram = "yadm";
  };
})
