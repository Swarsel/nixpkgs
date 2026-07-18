{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  fetchpatch2,
  flex,
  libtirpc,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "unfs3";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "unfs3";
    repo = "unfs3";
    tag = "unfs3-${version}";
    hash = "sha256-0IHpHW9lCPSltfl+VrS25tB9csISvTwCpD1oqwXpBwU=";
  };

  nativeBuildInputs = [
    flex
    bison
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libtirpc ];
  configureFlags = [ "--disable-shared" ];
  doCheck = false; # no test suite
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/unfsd";
  versionCheckProgramArg = "-h";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "${pname}-(.*)"
      ];
    };
  };

  meta = {
    description = "User-space NFSv3 file system server";

    longDescription = ''
      UNFS3 is a user-space implementation of the NFSv3 server
      specification.  It provides a daemon for the MOUNT and NFS
      protocols, which are used by NFS clients for accessing files on the
      server.
    '';

    homepage = "https://unfs3.github.io/";
    changelog = "https://raw.githubusercontent.com/unfs3/unfs3/unfs3-${version}/NEWS";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.unix;
    mainProgram = "unfsd";
  };
}
