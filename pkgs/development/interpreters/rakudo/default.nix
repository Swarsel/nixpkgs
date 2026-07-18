{
  lib,
  stdenv,
  fetchFromGitHub,
  nqp,
  perl,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rakudo";
  version = "2026.02";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "rakudo";
    repo = "rakudo";
    tag = finalAttrs.version;
    hash = "sha256-CqDZ+izOHNxi7sTt6jYqeF/ql5+2WdWBHvkS3N4JjNc=";
    fetchSubmodules = true;
  };

  patches = [
    ./rakudo-plain-wrapper.patch
  ];

  postPatch = ''
    substituteInPlace src/core.c/CompUnit/Repository/Installation.rakumod \
      --subst-var out
  '';

  configureFlags = [
    "--backends=moar"
    "--with-nqp=${lib.getExe nqp}"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  configureScript = "${lib.getExe perl} ./Configure.pl";

  meta = {
    description = "Raku implementation on top of Moar virtual machine";
    homepage = "https://rakudo.org";
    license = lib.licenses.artistic2;

    maintainers = with lib.maintainers; [
      thoughtpolice
      sgo
      prince213
    ];

    platforms = lib.platforms.unix;
    mainProgram = "rakudo";
  };
})
