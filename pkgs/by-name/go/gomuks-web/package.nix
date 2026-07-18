{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  libheif,
  nodejs,
  npmHooks,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "gomuks-web";
  version = "26.06";

  src = fetchFromGitHub {
    owner = "gomuks";
    repo = "gomuks";
    tag = "v0.${lib.replaceStrings [ "." ] [ "" ] finalAttrs.version}.0";
    hash = "sha256-Q4hu3bcB16iuqASZvlv7nDvxj8CFX66qWp6DHIUTmh4=";
  };

  postPatch = ''
    substituteInPlace ./web/build-wasm.sh \
      --replace-fail 'go.mau.fi/gomuks/version.Tag=$(git describe --exact-match --tags 2>/dev/null)' "go.mau.fi/gomuks/version.Tag=${finalAttrs.src.tag}" \
      --replace-fail 'go.mau.fi/gomuks/version.Commit=$(git rev-parse HEAD)' "go.mau.fi/gomuks/version.Commit=unknown"
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ];

  buildInputs = [
    libheif
  ];

  vendorHash = "sha256-iuSu5MvNRt+eCZ9wxUwMo6X0joos7q9WPyXBwhn/0yE=";

  env = {
    npmDeps = fetchNpmDeps {
      src = "${finalAttrs.src}/web";
      hash = "sha256-RiOes+tmAxhA9IkyA6yWQXTjjXyZg2Z8FmPTgcmCg/g=";
    };

    npmRoot = "web";
  };

  preBuild = ''
    CGO_ENABLED=0 go generate ./web
  '';

  doCheck = false;

  postInstall = ''
    mv $out/bin/gomuks $out/bin/gomuks-web
  '';

  ldflags = [
    "-X 'go.mau.fi/gomuks/version.Tag=${finalAttrs.src.tag}'"
    "-X 'go.mau.fi/gomuks/version.Commit=unknown'"
    "-X \"go.mau.fi/gomuks/version.BuildTime=$(date -Iseconds)\""
    "-X \"maunium.net/go/mautrix.GoModVersion=$(cat go.mod | grep 'maunium.net/go/mautrix ' | head -n1 | awk '{ print $2 })\""
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/gomuks"
    "cmd/gomuks-terminal"
    "cmd/archivemuks"
  ];

  tags = [
    "goolm"
    "libheif"
    "sqlite_fts5"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Matrix client written in Go";
    homepage = "https://github.com/tulir/gomuks";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.zaphyra ];
    platforms = lib.platforms.unix;
    mainProgram = "gomuks-web";
  };
})
