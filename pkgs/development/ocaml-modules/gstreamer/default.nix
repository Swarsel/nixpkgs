{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  glib,
  gst_all_1,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "gstreamer";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-gstreamer";
    rev = "v${finalAttrs.version}";
    sha256 = "0y8xi1q0ld4hrk96bn6jfh9slyjrxmnlhm662ynacp3yzalp8jji";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    glib.dev
    gst_all_1.gstreamer.dev
    gst_all_1.gst-plugins-base
  ];

  env.CFLAGS_COMPILE = toString [
    "-I${glib.dev}/include/glib-2.0"
    "-I${glib.out}/lib/glib-2.0/include"
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
    "-I${gst_all_1.gstreamer.dev}/include/gstreamer-1.0"
  ];

  meta = {
    description = "Bindings for the GStreamer library which provides functions for playning and manipulating multimedia streams";
    homepage = "https://github.com/savonet/ocaml-gstreamer";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
