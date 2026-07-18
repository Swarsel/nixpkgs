{
  lib,
  buildPythonPackage,
  fetchPypi,
  mitmproxy-rs,
}:

buildPythonPackage rec {
  inherit (mitmproxy-rs) version;
  pname = "mitmproxy-macos";

  # Note: if this isn't downloading, its because mitmproxy-rs updated without also updating this.
  src = fetchPypi {
    inherit version;
    hash = "sha256-baAfEY4hEN3wOEicgE53gY71IX003JYFyyZaNJ7U8UA=";
    dist = "py3";
    format = "wheel";
    pname = "mitmproxy_macos";
    python = "py3";
  };

  # repo has no python tests
  doCheck = false;
  format = "wheel";
  pythonImportsCheck = [ "mitmproxy_macos" ];

  meta = {
    inherit (mitmproxy-rs.meta) changelog license maintainers;
    description = "MacOS Rust bits in mitmproxy";
    homepage = "https://github.com/mitmproxy/mitmproxy_rs/tree/main/mitmproxy-macos";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.darwin;
  };
}
