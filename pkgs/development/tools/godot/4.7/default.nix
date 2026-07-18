{
  version = "4.7-stable";

  default = {
    exportTemplatesHash = "sha256-lxRFncBxkHwPPV8X1gj69p582iEzH8XTnEUD/6Tpnuw=";
  };

  hash = "sha256-ur9bQ6DTUxeTRqFITAgjpyoOEHgYnjEAQY3sSNNtr0c=";

  mono = {
    exportTemplatesHash = "sha256-TAKguZrZxbwkPC55RoYo2z34k1DZ24/JlZiPadEm4Gk=";
    nugetDeps = ./deps.json;
  };
}
