{ stdenv
, fetchFromGitHub
, fetchpatch
, pantheon
, pkgconfig
, meson
, python3
, ninja
, vala
, gtk3
, granite
, wingpanel
, evolution-data-server
, libical
, libgee
, libxml2
, libsoup
, elementary-calendar
, fetchurl
}:

let

  # Terrible workaround https://github.com/elementary/wingpanel-indicator-datetime/issues/122
  # Evolution Data Server functionality will be broken (events from calendar in indicator)
  # but at least we don't fail to build.
  old-evolution-data-server = evolution-data-server.overrideAttrs(old: {
    src = fetchurl {
      url = "mirror://gnome/sources/evolution-data-server/${stdenv.lib.versions.majorMinor "3.32.4"}/${old.pname}-3.32.4.tar.xz";
      sha256 = "0zsc9xwy6ixk3x0dx69ax5isrdw8qxjdxg2i5fr95s40nss7rxl3";
    };
  });

in

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-datetime";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "1y7a4xjwl3bpls56ys6g3s6mh5b3qbjm2vw7b6n2i4x7a63c4cbh";
  };

  passthru = {
    updateScript = pantheon.updateScript {
      repoName = pname;
    };
  };

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkgconfig
    python3
    vala
  ];

  buildInputs = [
    old-evolution-data-server
    granite
    gtk3
    libgee
    libical
    libsoup
    wingpanel
  ];

  patches = [
    # See: https://github.com/elementary/wingpanel-indicator-datetime/pull/117
    (fetchpatch {
      url = "https://github.com/elementary/wingpanel-indicator-datetime/commit/4859e72a52d8dac5cad87b192fc912fb013b0ecd.patch";
      sha256 = "0jfhb5sax4sivdfx7il1rc1dvhy0yfv27qhvwbdy0hza9wf8q9k0";
    })
  ];

  PKG_CONFIG_WINGPANEL_2_0_INDICATORSDIR = "${placeholder "out"}/lib/wingpanel";

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  meta = with stdenv.lib; {
    description = "Date & Time Indicator for Wingpanel";
    homepage = https://github.com/elementary/wingpanel-indicator-datetime;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
