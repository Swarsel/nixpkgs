{
  lib,
  stdenv,
  config,
  pkgs,
}:

lib.makeScope pkgs.newScope (
  self: with self; {

    GConf = callPackage ./platform/GConf { };
    ORBit2 = callPackage ./platform/ORBit2 { };
    # for git-head builds
    gnome-common = callPackage ./platform/gnome-common { };
    gnome_mime_data = callPackage ./platform/gnome-mime-data { };
    gtkglext = callPackage ./platform/gtkglext { };
    #### DESKTOP
    gtksourceview = callPackage ./desktop/gtksourceview { };

    #### PLATFORM
    libIDL = callPackage ./platform/libIDL {
      gettext = if stdenv.hostPlatform.isDarwin then pkgs.gettext else null;
    };

    libart_lgpl = callPackage ./platform/libart_lgpl { };
    libglade = callPackage ./platform/libglade { };
    libgnomecanvas = callPackage ./platform/libgnomecanvas { };

  }
)
// lib.optionalAttrs config.allowAliases {
  atk = throw "gnome2.atk has been removed, please use top-level atk";
  atkmm = throw "gnome2.atkmm has been removed, please use top-level atkmm";
  cairo = throw "gnome2.cairo has been removed, please use top-level cairo";
  # added 2024-12-02
  glib = throw "gnome2.glib has been removed, please use top-level glib";
  glibmm = throw "gnome2.glibmm has been removed, please use top-level glibmm";
  gnome-doc-utils = throw "gnome2.gnome-doc-utils has been removed, please use top-level gnome-doc-utils";
  gnome-icon-theme = throw "gnome2.gnome-icon-theme has been removed, please use top-level gnome-icon-theme";
  gnome_common = throw "gnome2.gnome_common has been removed, please use top-level gnome-common";
  gnome_icon_theme = throw "gnome2.gnome_icon_theme has been removed, please use top-level gnome-icon-theme";
  gnome_python = throw "gnome2.gnome_python has been removed"; # 2023-01-14
  gnome_python_desktop = throw "gnome2.gnome_python_desktop has been removed"; # 2023-01-14
  gnome_vfs = throw "gnome2.gnome_vfs has been removed"; # 2024-06-27
  gnomedocutils = throw "gnome2.gnomedocutils has been removed, please use top-level gnome-doc-utils";
  gnomeicontheme = throw "gnome2.gnomeicontheme has been removed, please use top-level gnome-icon-theme";
  gtk = throw "gnome2.gtk has been removed, please use top-level gtk2";
  gtk-doc = throw "gnome2.gtk-doc has been removed, please use top-level gtk-doc";
  gtkdoc = throw "gnome2.gtkdoc has been removed, please use top-level gtk-doc";
  gtkhtml = throw "gnome2.gtkhtml has been removed"; # 2023-01-15
  gtkhtml4 = throw "gnome2.gtkhtml4 has been removed"; # 2023-01-15
  gtkmm = throw "gnome2.gtkmm has been removed, please use top-level gtkmm2";
  gtkmm2 = throw "gnome2.gtkmm2 has been removed, please use top-level gtkmm2";
  gvfs = throw "gnome2.gvfs has been removed, please use top-level gvfs";
  libbonobo = throw "gnome2.libbonobo has been removed"; # 2024-06-27
  libbonoboui = throw "gnome2.libbonoboui has been removed"; # 2024-06-27
  libcanberra-gtk2 = throw "gnome2.libcanberra-gtk2 has been removed, please use top-level libcanberra-gtk2";
  libglademm = throw "gnome2.libglademm has been removed"; # 2022-01-15
  libgnome = throw "gnome2.libgnome has been removed"; # 2024-06-27
  libgnomecanvasmm = throw "gnome2.libgnomecanvasmm has been removed"; # 2022-01-15
  libgnomecups = throw "gnome2.libgnomecups has been removed"; # 2023-01-15
  libgnomeprint = throw "gnome2.libgnomeprint has been removed"; # 2023-01-15
  libgnomeprintui = throw "gnome2.libgnomeprintui has been removed"; # 2023-01-15
  libgnomeui = throw "gnome2.libgnomeui has been removed"; # 2024-06-27
  libgtkhtml = throw "gnome2.libgtkhtml has been removed"; # 2023-01-15
  libsoup = throw "gnome2.libsoup has been removed, please use top-level libsoup_2_4";
  libwnck2 = throw "gnome2.libwnck2 has been removed, please use top-level libwnck2";
  pango = throw "gnome2.pango has been removed, please use top-level pango";
  pangomm = throw "gnome2.pangomm has been removed, please use top-level pangomm";
  python_rsvg = throw "gnome2.python_rsvg has been removed"; # 2023-01-14
  startup_notification = throw "gnome2.startup_notification has been removed, please use top-level libstartup_notification";
  startupnotification = throw "gnome2.startupnotification has been removed, please use top-level libstartup_notification";
}
