{
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  rustPlatform,
  sqlcipher,
  yarn,
  yarnBuildHook,
  yarnConfigHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seshat-node";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "seshat";
    tag = finalAttrs.version;
    hash = "sha256-2v/qXMCD+r+CSQHtP/YT62p4GoApbGz33kcZfJAKbOU=";
  };

  nativeBuildInputs = [
    nodejs
    yarn
    yarnConfigHook
    yarnBuildHook
  ];

  buildInputs = [ sqlcipher ];
  cargoHash = "sha256-krSm1wy7HkCOLEHPPHCx6V9Mj+FiavyhO6bLOz2/3Qw=";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    mv "index."{node,js} "$out"

    runHook postInstall
  '';

  disallowedReferences = [ stdenv.cc.cc ];
  sourceRoot = "${finalAttrs.src.name}/seshat-node";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-hh9n8By/dNdKS55rcZkzCxmJWwQa6Ovt+4M3YP3/hDs=";
    yarnLock = finalAttrs.src + "/seshat-node/yarn.lock";
  };
})
