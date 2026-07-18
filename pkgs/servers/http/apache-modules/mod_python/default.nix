{
  lib,
  stdenv,
  fetchFromGitHub,
  apacheHttpd,
  ensureNewerSourcesForZipFilesHook,
  libintl,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mod_python";
  version = "3.5.0.7";

  src = fetchFromGitHub {
    owner = "grisha";
    repo = "mod_python";
    tag = finalAttrs.version;
    hash = "sha256-8LbkwbY5vsRQhbqkXytBxM+MVMtnwRa61nrKHbI4Vtg=";
  };

  patches = [ ./install.patch ];

  nativeBuildInputs = [
    ensureNewerSourcesForZipFilesHook
  ];

  buildInputs = [
    apacheHttpd
    (python3.withPackages (
      ps: with ps; [
        distutils
        packaging
        setuptools
      ]
    ))
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libintl
  ];

  installFlags = [
    "LIBEXECDIR=$(out)/modules"
    "BINDIR=$(out)/bin"
  ];

  passthru = {
    inherit apacheHttpd;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Apache module that embeds the Python interpreter within the server";
    homepage = "https://modpython.org/";
    changelog = "https://github.com/grisha/mod_python/blob/master/NEWS";
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "mod_python";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
