{
  lib,
  stdenv,
  fetchFromGitHub,
  binaryen,
  cargo,
  fetchPnpmDeps,
  fetchpatch,
  libfido2,
  makeWrapper,
  nixosTests,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  rustc,
  wasm-pack,
  xdg-utils,
}:

{
  buildGoModule,
  cargoHash,
  hash,
  pnpmHash,
  vendorHash,
  version,
  wasm-bindgen-cli,
  extPatches ? [ ],
  withRdpClient ? true,
}:
let

  # This repo has a private submodule "e" which fetchgit cannot handle without failing.
  src = fetchFromGitHub {
    inherit hash;
    owner = "gravitational";
    repo = "teleport";
    tag = "v${version}";
  };
  pname = "teleport";
  inherit version;

  rdpClient = rustPlatform.buildRustPackage (finalAttrs: {
    inherit cargoHash;
    inherit version src;
    pname = "teleport-rdpclient";
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
    env.OPENSSL_NO_VENDOR = "1";
    # https://github.com/NixOS/nixpkgs/issues/161570 ,
    # buildRustPackage sets strictDeps = true;
    nativeCheckInputs = finalAttrs.buildInputs;

    postInstall = ''
      mkdir -p $out/include
      cp ${finalAttrs.buildAndTestSubdir}/librdpclient.h $out/include/
    '';

    buildAndTestSubdir = "lib/srv/desktop/rdp/rdpclient";
  });

  webassets = stdenv.mkDerivation {
    inherit src version;
    pname = "teleport-webassets";

    patches = [
      ./disable-wasm-opt-for-ironrdp.patch
    ];

    nativeBuildInputs = [
      binaryen
      cargo
      nodejs
      pnpmConfigHook
      pnpm_10
      rustc
      rustc.llvmPackages.lld
      rustPlatform.cargoSetupHook
      wasm-bindgen-cli
      wasm-pack
    ];

    buildPhase = ''
      PATH=$PATH:$PWD/node_modules/.bin

      pushd web/packages
      pushd shared
      # https://github.com/gravitational/teleport/blob/6b91fe5bbb9e87db4c63d19f94ed4f7d0f9eba43/web/packages/teleport/README.md?plain=1#L18-L20
      RUST_MIN_STACK=16777216 wasm-pack build ./libs/ironrdp --target web --mode no-install
      popd
      pushd teleport
      vite build
      popd
      popd
    '';

    installPhase = ''
      mkdir -p $out
      cp -R webassets/. $out
    '';

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      hash = cargoHash;
    };

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)

      runHook postConfigure
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit
        src
        pname
        version
        ;

      fetcherVersion = 3;
      hash = pnpmHash;
      pnpm = pnpm_10;
    };
  };
in
buildGoModule (finalAttrs: {
  inherit pname src version;
  inherit vendorHash;

  # Reduce closure size for client machines
  outputs = [
    "out"
    "client"
  ];

  patches =
    extPatches
    ++ [
      ./rdpclient.patch
    ]
    ++ lib.optional (lib.versionOlder version "18.8.0") [
      ./0001-fix-add-nix-path-to-exec-env.patch
    ]
    ++ lib.optional (lib.versionAtLeast version "18.8.0") [
      ./0001-fix-add-nix-path-to-exec-env-reexec.patch
    ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
    libfido2
  ];

  preBuild = ''
    cp -r ${webassets} webassets
  ''
  + lib.optionalString withRdpClient ''
    ln -s ${rdpClient}/lib/* lib/
    ln -s ${rdpClient}/include/* lib/srv/desktop/rdp/rdpclient/
  '';

  # Multiple tests fail in the build sandbox
  # due to trying to spawn nixbld's shell (/noshell), etc.
  doCheck = false;

  postInstall = ''
    mkdir -p $client/bin
    mv {$out,$client}/bin/tsh
    # make xdg-open overrideable at runtime
    wrapProgram $client/bin/tsh --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
    ln -s {$client,$out}/bin/tsh
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    export HOME=$(mktemp -d)
    $out/bin/tsh version | grep ${version} > /dev/null
    $client/bin/tsh version | grep ${version} > /dev/null
    $out/bin/tbot version | grep ${version} > /dev/null
    $out/bin/tctl version | grep ${version} > /dev/null
    $out/bin/teleport version | grep ${version} > /dev/null
  '';

  proxyVendor = true;

  subPackages = [
    "tool/tbot"
    "tool/tctl"
    "tool/teleport"
    "tool/tsh"
  ];

  tags = [
    "libfido2"
    "webassets_embed"
  ]
  ++ lib.optional withRdpClient "desktop_access_rdp";

  passthru.tests = nixosTests.teleport;

  meta = {
    description = "Certificate authority and access plane for SSH, Kubernetes, web applications, and databases";
    homepage = "https://goteleport.com/";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      arianvp
      justinas
      sigma
      tomberek
      techknowlogick
      juliusfreudenberger
    ];

    platforms = lib.platforms.unix;
    # go-libfido2 is broken on platforms with less than 64-bit because it defines an array
    # which occupies more than 31 bits of address space.
    broken = stdenv.hostPlatform.parsed.cpu.bits < 64;
  };
})
