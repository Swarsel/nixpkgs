{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  withUI ? true,
}:

buildGoModule (finalAttrs: {
  pname = "exatorrent";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "varbhat";
    repo = "exatorrent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FvL3ekpj1HwARgY3vj0xAwCgDBa97OqtFFY4rSBKr50=";
  };

  nativeBuildInputs = lib.optionals withUI [
    npmHooks.npmConfigHook
    nodejs
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isGnu [
    stdenv.cc.libc.static
  ];

  vendorHash = "sha256-fE+GVQ2HAfElO1UDmDMeu2ca7t5yNs83CXhqgT0t1Js=";
  # Fix build with GCC 15
  # from vendor/github.com/anacrolix/go-libutp/callbacks.go:4:
  # ./utp_types.h:120:15: error: two or more data types in declaration specifiers
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  preBuild = lib.optionalString withUI ''
    pushd "$npmRoot"
    npm run build
    popd
  '';

  ldflags = [
    "-s"
    "-w"
  ]
  ++ lib.optionals stdenv.hostPlatform.isGnu [
    # upstream also tries to compile statically if possible
    "-extldflags '-static'"
  ];

  npmDeps =
    if withUI then
      fetchNpmDeps {
        inherit (finalAttrs) src;
        hash = "sha256-eNrBKTW4KlLNf/Y9NTvGt5r28MG7SLGzUi+p9mOyrmI=";
        name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
        sourceRoot = "${finalAttrs.src.name}/${finalAttrs.npmRoot}";
      }
    else
      null;

  npmRoot = "internal/web";

  # I dislike the fact that buildGoModule's fetcher FOD automatically inherits some attrs from the non-FOD part
  overrideModAttrs = prev: {
    nativeBuildInputs = lib.filter (e: e != npmHooks.npmConfigHook) prev.nativeBuildInputs;
    preBuild = "";
  };

  tags = lib.optionals (!withUI) [ "noui" ];

  meta = {
    description = "Self-hostable, easy-to-use, lightweight, and feature-rich torrent client written in Go";
    homepage = "https://github.com/varbhat/exatorrent/";
    changelog = "https://github.com/varbhat/exatorrent/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "exatorrent";
  };
})
