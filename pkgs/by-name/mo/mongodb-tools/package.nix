{
  lib,
  fetchFromGitHub,
  buildGoModule,
  krb5,
  libpcap,
  nix-update-script,
  openssl,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "mongo-tools";
  version = "100.17.0";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "mongo-tools";
    tag = finalAttrs.version;
    hash = "sha256-lR0pEZgDoIW9HYfutrPa1fNqLLANcw5oS2jATuPSBLo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    libpcap
    krb5
  ];

  vendorHash = null;

  # Mongodb incorrectly names all of their binaries main
  # Let's work around this with our own installer
  buildPhase =
    let
      tools = [
        "bsondump"
        "mongodump"
        "mongoexport"
        "mongofiles"
        "mongoimport"
        "mongorestore"
        "mongostat"
        "mongotop"
      ];
    in
    ''
      # move vendored codes so nixpkgs go builder could find it
      runHook preBuild

      ${lib.concatMapStrings (t: ''
        go build -o "$out/bin/${t}" -tags "gssapi ssl" -ldflags "-s -w" ./${t}/main
      '') tools}

      runHook postBuild
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools for the MongoDB";
    homepage = "https://github.com/mongodb/mongo-tools";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      iamanaws
    ];
  };
})
