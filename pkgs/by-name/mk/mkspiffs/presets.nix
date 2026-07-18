{ lib, mkspiffs }:

# We provide the same presets as the upstream

lib.mapAttrs
  (
    name:
    { CPPFLAGS }:
    mkspiffs.overrideAttrs {
      env = {
        BUILD_CONFIG_NAME = "-${name}";
        CPPFLAGS = toString CPPFLAGS;
      };
    }
  )
  {
    arduino-esp32.CPPFLAGS = [ "-DSPIFFS_OBJ_META_LEN=4" ];

    arduino-esp8266.CPPFLAGS = [
      "-DSPIFFS_USE_MAGIC_LENGTH=0"
      "-DSPIFFS_ALIGNED_OBJECT_INDEX_TABLES=1"
    ];

    esp-idf.CPPFLAGS = [ "-DSPIFFS_OBJ_META_LEN=4" ];
  }
