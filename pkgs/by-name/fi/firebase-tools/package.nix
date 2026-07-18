{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nodejs_22,
  python3,
  xcbuild,
}:

buildNpmPackage rec {
  pname = "firebase-tools";
  version = "15.22.4";

  src = fetchFromGitHub {
    owner = "firebase";
    repo = "firebase-tools";
    tag = "v${version}";
    hash = "sha256-0O6/tOd9PNtsTzXvgFMl7bneejMJ4uAGvinWZFjlkUo=";
  };

  # No more package-lock.json in upstream src
  postPatch = ''
    cp ./npm-shrinkwrap.json ./package-lock.json
  '';

  nativeBuildInputs = [
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild
  ];

  npmDepsHash = "sha256-TlAcsOKmHnXPNdOpgXhr16tMWFjtahT/CG5INBR59fM=";
  env.PUPPETEER_SKIP_DOWNLOAD = true;
  nodejs = nodejs_22;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage, and deploy your Firebase project from the command line";
    homepage = "https://github.com/firebase/firebase-tools";
    changelog = "https://github.com/firebase/firebase-tools/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];

    mainProgram = "firebase";
  };
}
