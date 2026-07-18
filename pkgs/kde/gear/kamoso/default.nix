{
  frei0r,
  gst_all_1,
  kirigami-addons,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kamoso";

  preFixup = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  extraBuildInputs = [
    kirigami-addons
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { qt6Support = true; })
    gst_all_1.gst-plugins-bad
  ];

  extraNativeBuildInputs = [ pkg-config ];
  qtWrapperArgs = [ "--set FREI0R_PATH ${frei0r}/lib/frei0r-1" ];
}
