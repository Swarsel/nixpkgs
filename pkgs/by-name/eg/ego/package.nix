{
  lib,
  fetchFromGitHub,
  acl,
  libxcb,
  makeBinaryWrapper,
  rustPlatform,
  xhost,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ego";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "intgr";
    repo = "ego";
    tag = finalAttrs.version;
    hash = "sha256-TO0jyi6XGPfuF7s4vTV8uT43SjCGUx6cVZONyb5e93Q=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  buildInputs = [
    acl
    libxcb
  ];

  cargoHash = "sha256-MmcZrjjNvc3C/RRMCQsuaJT4sf+gTAaxVDtKGHjKqc8=";

  # requires access to /root
  checkFlags = [
    "--skip=tests::test_check_user_homedir"
  ];

  preCheck = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ libxcb ]}:$LD_LIBRARY_PATH"
  '';

  postInstall = ''
    wrapProgram $out/bin/ego \
      --prefix PATH : ${lib.makeBinPath [ xhost ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libxcb ]}
  '';

  meta = {
    description = "Run Linux desktop applications under a different local user";
    homepage = "https://github.com/intgr/ego";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mio
    ];

    mainProgram = "ego";
  };
})
