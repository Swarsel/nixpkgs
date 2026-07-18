{
  lib,
  stdenv,
  fetchCrate,
  rust-cbindgen,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tun2proxy";
  version = "0.7.20";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-nc12hjKOUGuxkNsbTMkHYv4HSLGwemx2VKv18u0rvn8=";
    pname = "tun2proxy";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [ rust-cbindgen ];
  cargoHash = "sha256-iK5lUu6HWaNMA0I+sIpUr5pNwI05szctxzW6cPSyH3g=";
  env.GIT_HASH = "000000000000000000000000000000000000000000000000000";

  postBuild = ''
    cbindgen --config cbindgen.toml -o target/tun2proxy.h
  '';

  installPhase = ''
    runHook preInstall

    install -D target/${stdenv.hostPlatform.rust.rustcTarget}/release/tun2proxy-bin -t $out/bin
    install -D target/${stdenv.hostPlatform.rust.rustcTarget}/release/udpgw-server -t $out/bin

    install -D target/tun2proxy.h -t $dev/include

    install -D target/${stdenv.hostPlatform.rust.rustcTarget}/release/libtun2proxy.a -t $lib/lib
    install -D target/${stdenv.hostPlatform.rust.rustcTarget}/release/libtun2proxy${stdenv.hostPlatform.extensions.library} -t $lib/lib

    runHook postInstall
  '';

  meta = {
    description = "Tunnel (TUN) interface for SOCKS and HTTP proxies";
    homepage = "https://github.com/tun2proxy/tun2proxy";
    changelog = "https://github.com/tun2proxy/tun2proxy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mksafavi ];
    mainProgram = "tun2proxy-bin";
  };
})
