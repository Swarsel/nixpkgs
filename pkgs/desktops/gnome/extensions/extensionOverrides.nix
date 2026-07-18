{
  lib,
  fetchFromGitLab,
  cpio,
  cups,
  ddcutil,
  desktop-file-utils,
  easyeffects,
  gjs,
  glib,
  gnome-menus,
  gobject-introspection,
  gsound,
  gtk3,
  gtk4,
  hddtemp,
  libgda6,
  libgtop,
  libhandy,
  liquidctl,
  lm_sensors,
  nautilus,
  netcat-gnu,
  nvme-cli,
  procps,
  replaceVars,
  smartmontools,
  stdenvNoCC,
  touchegg,
  util-linux,
  vte,
  wrapGAppsHook3,
  xdg-user-dirs,
  xdg-utils,
}:
let
  # Helper method to reduce redundancy
  patchExtension =
    name: override: super:
    (
      super
      // {
        ${name} = super.${name}.overrideAttrs override;
      }
    );
in
# A set of overrides for automatically packaged extensions that require some small fixes.
# The input must be an attribute set with the extensions' UUIDs as keys and the extension
# derivations as values. Output is the same, but with patches applied.
#
# Note that all source patches refer to the built extension as published on extensions.gnome.org, and not
# the upstream repository's sources.
super:
lib.trivial.pipe super [
  (patchExtension "apps-menu@gnome-shell-extensions.gcampax.github.com" (old: {
    patches = [
      (replaceVars
        ./extensionOverridesPatches/apps-menu_at_gnome-shell-extensions.gcampax.github.com.patch
        {
          gmenu_path = "${gnome-menus}/lib/girepository-1.0";
        }
      )
    ];
  }))

  (patchExtension "caffeine@patapon.info" (old: {
    meta.maintainers = with lib.maintainers; [ eperuffo ];
  }))

  (patchExtension "copyous@boerdereinar.dev" (old: {
    buildInputs = [
      libgda6
      gsound
    ];

    preInstall = ''
      sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${libgda6}/lib/girepository-1.0');\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/preferences/dependencies/dependencies.js
      sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${libgda6}/lib/girepository-1.0');\n" lib/database/entryTracker.js
      sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/common/sound.js
      sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/preferences/general/feedbackSettings.js
    '';
  }))

  (patchExtension "dash-to-dock@micxgx.gmail.com" (old: {
    meta.maintainers = with lib.maintainers; [ rhoriguchi ];
  }))

  (patchExtension "ddterm@amezin.github.com" (old: {
    nativeBuildInputs = [
      gobject-introspection
      wrapGAppsHook3
    ];

    buildInputs = [
      vte
      libhandy
      gjs
    ];

    postFixup = ''
      patchShebangs "$out/share/gnome-shell/extensions/ddterm@amezin.github.com/bin/com.github.amezin.ddterm"
      wrapGApp "$out/share/gnome-shell/extensions/ddterm@amezin.github.com/bin/com.github.amezin.ddterm"
    '';
  }))

  (patchExtension "ding@rastersoft.com" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/ding_at_rastersoft.com.patch {
        inherit gjs;
        gtk3_gsettings_path = glib.getSchemaPath gtk3;
        nautilus_gsettings_path = glib.getSchemaPath nautilus;
        typelib_path = "${gtk3}/lib/girepository-1.0";
        util_linux = util-linux;
        xdg_utils = xdg-utils;
      })
    ];

    nativeBuildInputs = [ wrapGAppsHook3 ];
  }))

  (patchExtension "display-brightness-ddcutil@themightydeity.github.com" (old: {
    # Has a hard-coded path to a run-time dependency
    # https://github.com/NixOS/nixpkgs/issues/136111
    postPatch = ''
      substituteInPlace "schemas/org.gnome.shell.extensions.display-brightness-ddcutil.gschema.xml" \
        --replace-fail "/usr/bin/ddcutil" ${lib.getExe ddcutil}
    '';

    # Make glib-compile-schemas available
    nativeBuildInputs = [ glib ];

    postFixup = ''
      rm "$out/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com/schemas/gschemas.compiled"
      glib-compile-schemas "$out/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com/schemas"
    '';
  }))

  (patchExtension "eepresetselector@ulville.github.io" (old: {
    patches = [
      # Needed to find the currently set preset
      (replaceVars ./extensionOverridesPatches/eepresetselector_at_ulville.github.io.patch {
        easyeffects_gsettings_path = "${glib.getSchemaPath easyeffects}";
      })
    ];
  }))

  (patchExtension "freon@UshakovVasilii_Github.yahoo.com" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/freon_at_UshakovVasilii_Github.yahoo.com.patch {
        inherit
          hddtemp
          liquidctl
          lm_sensors
          procps
          smartmontools
          ;

        netcat = netcat-gnu;
        nvmecli = nvme-cli;
      })
    ];
  }))

  (patchExtension "gtk4-ding@smedius.gitlab.com" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/gtk4-ding_at_smedius.gitlab.com.patch {
        inherit gjs;
        gtk_update_icon_cache = "${gtk4.out}/bin/gtk4-update-icon-cache";
        nautilus_gsettings_path = glib.getSchemaPath nautilus;
        update_desktop_database = "${desktop-file-utils.out}/bin/update-desktop-database";
        util_linux = util-linux;
        xdg_utils = xdg-utils;
      })
    ];

    nativeBuildInputs = [ wrapGAppsHook3 ];
  }))

  (patchExtension "lunarcal@ailin.nemui" (
    old:
    let
      chinese-calendar = stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "chinese-calendar";
        version = "20240107";

        src = fetchFromGitLab {
          owner = "Nei";
          repo = "ChineseCalendar";
          tag = finalAttrs.version;
          hash = "sha256-z8Af9e70bn3ztUZteIEt/b3nJIFosbnoy8mwKMM6Dmc=";
          domain = "gitlab.gnome.org";
        };

        nativeBuildInputs = [
          cpio # used in install.sh
        ];

        installPhase = ''
          runHook preInstall
          HOME=$out ./install.sh
          runHook postInstall
        '';
      });
    in
    {
      patches = [
        (replaceVars ./extensionOverridesPatches/lunarcal_at_ailin.nemui.patch {
          chinese_calendar_path = chinese-calendar;
        })
      ];
    }
  ))

  (patchExtension "printers@linux-man.org" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/printers_at_linux-man.org.patch {
        inherit cups;
      })
    ];
  }))

  (patchExtension "system-monitor@gnome-shell-extensions.gcampax.github.com" (old: {
    patches = [
      (replaceVars
        ./extensionOverridesPatches/system-monitor_at_gnome-shell-extensions.gcampax.github.com.patch
        {
          gtop_path = "${libgtop}/lib/girepository-1.0";
        }
      )
    ];
  }))

  (patchExtension "system-monitor-next@paradoxxx.zero.gmail.com" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/system-monitor-next_at_paradoxxx.zero.gmail.com.patch {
        gtop_path = "${libgtop}/lib/girepository-1.0";
      })
    ];

    meta.maintainers = with lib.maintainers; [ andersk ];
  }))

  (patchExtension "Vitals@CoreCoding.com" (old: {
    patches = [
      (replaceVars ./extensionOverridesPatches/vitals_at_corecoding.com.patch {
        gtop_path = "${libgtop}/lib/girepository-1.0";
      })
    ];
  }))

  (patchExtension "x11gestures@joseexposito.github.io" (old: {
    # Extension can't find Touchegg
    # https://github.com/NixOS/nixpkgs/issues/137621
    postPatch = ''
      substituteInPlace "src/touchegg/ToucheggConfig.js" \
        --replace "GLib.build_filenamev([GLib.DIR_SEPARATOR_S, 'usr', 'share', 'touchegg', 'touchegg.conf'])" "'${touchegg}/share/touchegg/touchegg.conf'"
    '';
  }))

  (patchExtension "pwcalc@thilomaurer.de" {
    postPatch = ''
      # remove unused dangling symlink
      rm settings-importexport.ui
    '';
  })

  (patchExtension "TeaTimer@zener.sbg.at" {
    postPatch = ''
      # remove unused dangling symlink
      rm utilities-teatime.svg
    '';
  })

  (patchExtension "named-workspaces@a31.at" {
    postPatch = ''
      # remove duplicate schema file
      rm schemas/org.gnome.shell.extensions.workspace-name.gschema.xml
    '';
  })
]
