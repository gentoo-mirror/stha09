# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk vi zh-CN zh-TW"

inherit chromium-2 desktop unpacker xdg-utils

DESCRIPTION="Microsoft Teams, an Office 365 multimedia collaboration client, pre-release"
HOMEPAGE="https://products.office.com/en-us/microsoft-teams/group-chat-software/"
SRC_URI="https://packages.microsoft.com/repos/ms-teams/pool/main/t/${PN}/${PN}_${PV}_amd64.deb"

LICENSE="ms-teams-pre"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror splitdebug test"
IUSE="swiftshader system-ffmpeg"

QA_PREBUILT="*"

# libasound2 (>= 1.0.16), libatk-bridge2.0-0 (>= 2.5.3), libatk1.0-0 (>= 1.12.4), libc6 (>= 2.17), libcairo2 (>= 1.10.0), libcups2 (>= 1.4.0),
# libexpat1 (>= 2.0.1), libgcc1 (>= 1:3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.35.8), libgtk-3-0 (>= 3.10.0), libnspr4 (>= 2:4.9-2~), libnss3
# (>= 2:3.22), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libsecret-1-0 (>= 0.7),libuuid1 (>= 2.16), libx11-6 (>= 2:1.4.99.1), libx11-xcb1,
# libxcb1 (>= 1.6), libxcomposite1 (>= 1:0.3-1), libxcursor1 (>> 1.1.2), libxdamage1 (>= 1:1.1), libxext6, libxfixes3, libxi6 (>= 2:1.2.99.4), libxkbfile
# libxrandr2 (>= 2:1.2.99.3), libxrender1, libxss1, libxtst6, apt-transport-https, libfontconfig1 (>= 2.11.0), libdbus-1-3 (>= 1.6.18), libstdc++6 (>= 4.8.1)
RDEPEND="
	app-accessibility/at-spi2-atk
	app-crypt/libsecret
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbfile
	x11-libs/pango
	system-ffmpeg? ( <media-video/ffmpeg-4.3[chromium] )
"

S="${WORKDIR}"

src_prepare() {
	default
	sed -i '/OnlyShowIn=/d' usr/share/applications/${PN}.desktop || die
}

src_install() {
	rm _gpgorigin || die
	doins -r .

	pushd "${ED}/usr/share/${PN}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	rm -rf "${ED}/usr/share/${PN}/resources/assets/"{.gitignore,macos,tlb,windows,x86,x64,arm64} || die
	rm -rf "${ED}/usr/share/${PN}/resources/tmp" || die

	if use system-ffmpeg; then
		rm -f "${ED}/usr/share/${PN}/libffmpeg.so" || die
		dosym "../../$(get_libdir)/chromium/libffmpeg.so" "usr/share/${PN}/libffmpeg.so" || die
	fi

	if ! use swiftshader; then
		rm -rf "${ED}/usr/share/${PN}/swiftshader" || die
	fi

	fperms +x /usr/bin/${PN}
	fperms +x /usr/share/${PN}/${PN}
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
