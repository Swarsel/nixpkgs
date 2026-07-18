{
  lib,
  bpf-linker,
  buildPythonPackage,
  mitmproxy-rs,
  rustPlatform,
}:

buildPythonPackage {
  inherit (mitmproxy-rs) version src cargoDeps;
  pname = "mitmproxy-linux";

  postPatch = ''
    substituteInPlace ../mitmproxy-rs-*-vendor/*/aya-build-*/src/lib.rs \
      --replace-fail '"+nightly",' "" \
      --replace-fail '"-Z",' "" \
      --replace-fail '"build-std=core",' ""

    substituteInPlace mitmproxy-linux-ebpf/.cargo/config.toml \
      --replace-fail 'build-std = ["core"]' ""

    cp ${./fix-mitmproxy-linux-redirector-path.diff} tmp.diff
    substituteInPlace tmp.diff \
      --replace-fail @mitmproxy-linux-redirector@ $out/bin/mitmproxy-linux-redirector
    patch -p1 < tmp.diff
  '';

  nativeBuildInputs = [
    bpf-linker
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  env = {
    RUSTC_BOOTSTRAP = 1;
    RUSTFLAGS = "-C target-feature=";
  };

  # repo has no python tests
  doCheck = false;
  buildAndTestSubdir = "mitmproxy-linux";
  pyproject = true;
  pythonImportsCheck = [ "mitmproxy_linux" ];

  meta = {
    inherit (mitmproxy-rs.meta) changelog license maintainers;
    description = "Linux Rust bits in mitmproxy";
    homepage = "https://github.com/mitmproxy/mitmproxy_rs/tree/main/mitmproxy-linux";
    platforms = lib.platforms.linux;
  };
}
