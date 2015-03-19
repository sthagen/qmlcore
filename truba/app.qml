FragmentActivity {
	id: mainWindow;
	anchors.fill: renderer;
	// anchors.leftMargin: 75;
	// anchors.rightMargin: 75;
	// anchors.bottomMargin: 40;
	anchors.topMargin: 70;
	name: "root";

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		source: "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;
	}

	ColorTheme { id: colorTheme; }
	Protocol { id: protocol; enabled: true; }

	MouseArea {
		anchors.fill: renderer;
		hoverEnabled: !parent.hasAnyActiveChild || parent.currentActivity == "infoPanel";

		onMouseXChanged: { 
			if (this.hoverEnabled)
				infoPanel.start();
		}

		onMouseYChanged: {
			if (this.hoverEnabled) 
				infoPanel.start();
		}
	}

	InfoPanel {
		id: infoPanel;
		anchors.fill: parent;

		onMenuCalled: { mainMenu.start(); }
	}

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: renderer.top;
	 	active: parent.hasAnyActiveChild;
	 	z: 10;

		onOptionChoosed(option): {
			if (option === "epg")
				mainPageStack.currentIndex = 1;
			else if (option === "channelList")
				mainPageStack.currentIndex = 0;
			else if (option === "movies")
				mainPageStack.currentIndex = 2;
			else if (option === "settings")
				mainPageStack.currentIndex = 3;
		}

		onDownPressed: { mainPageStack.forceActiveFocus(); }

		onCloseAll: {
			if (infoPanel.active)
				infoPanel.stop();
			else
				infoPanel.start();
		}
	}

	PageStack {
		id: mainPageStack;
		anchors.top: mainMenu.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 1;
		visible: mainMenu.activeFocus || activeFocus;

		ChannelsPanel {
			id: channelsPanel;
			protocol: parent.protocol;

			onChannelSwitched(url): { videoPlayer.source = url; }
		}

		EPGPanel { id: epgPanel; }
		VODPanel { id: vodPanel; }
		SettingsPanel { }

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	onRedPressed: { vodPanel.start(); }
	onBluePressed: { infoPanel.start(); }
	onGreenPressed: { channelsPanel.start(); }
	onYellowPressed: { epgPanel.start(); }
}
