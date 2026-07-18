{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  darkdetect,
  packaging,
  setuptools,
  tkinter,
  typing-extensions,
}:
let
  pname = "customtkinter";
  version = "5.2.2";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "TomSchimansky";
    repo = "CustomTkinter";
    tag = "v${version}";
    hash = "sha256-1g2wdXbUv5xNnpflFLXvU39s16kmwvuegKWd91E3qm4=";
  };

  patches = [ ./0001-Add-Missing-Cfg-Packages.patch ];

  build-system = [
    setuptools
    tkinter
  ];

  dependencies = [
    darkdetect
    packaging
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "customtkinter" ];

  meta = {
    description = "Modern and customizable python UI-library based on Tkinter";

    longDescription = ''
      CustomTkinter is a python UI-library based on Tkinter, which provides
      new, modern and fully customizable widgets. They are created and
      used like normal Tkinter widgets and can also be used in combination
      with normal Tkinter elements. The widgets and the window colors
      either adapt to the system appearance or the manually set mode
      ('light', 'dark'), and all CustomTkinter widgets and windows support
      HighDPI scaling (Windows, macOS). With CustomTkinter you'll get
      a consistent and modern look across all desktop platforms
      (Windows, macOS, Linux).
    '';

    homepage = "https://github.com/TomSchimansky/CustomTkinter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _4evy ];
  };
}
