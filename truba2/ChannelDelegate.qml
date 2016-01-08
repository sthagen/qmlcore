MouseArea {
	id: channelDelegateProto;
	signal epgCalled;
	property bool toggled: false;
	property int spacing: (height - channelLabelText.paintedHeight - 2 * durationText.font.pixelSize) / 4;
	width: parent.width;
	height: channelLabelText.paintedHeight * 3.5;
	hoverEnabled: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.focusablePanelColor;
	}

	Rectangle {
		id: blinkRect;
		anchors.fill: parent;
		color: channelDelegateProto.toggled ? colorTheme.accentColor : colorTheme.activeFocusColor;
		visible: parent.activeFocus;

		Behavior on color { ColorAnimation { duration: 300; } }
	}

	Rectangle {
		id: logoBg;
		width: height;
		color: model.color;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		clip: true;

		Rectangle {
			color: "#0000";
			anchors.fill: parent;
			anchors.topMargin: 4;
			anchors.leftMargin: 4;
			anchors.bottomMargin: 4;
			border.width: 4;
			border.color: colorTheme.activeFocusColor;
			visible: channelDelegateProto.activeFocus;
		}

		SmallText {
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: paintedWidth > logoBg.width - 10 ? 5 : (logoBg.width - paintedWidth) / 2;
			text: model.text;
			color: colorTheme.focusedTextColor;
			visible: channelLogo.status != Image.Ready;
		}

		Image {
			id: channelLogo;
			anchors.fill: parent;
			anchors.margins: 10;
			fillMode: Image.PreserveAspectFit;
			source: model.source;
		}
	}

	Item {
		anchors.fill: parent;
		clip: true;

		MainText {
			id: channelLabelText;
			anchors.top: parent.top;
			anchors.left: logoBg.right;
			anchors.right: parent.right;
			anchors.margins: channelDelegateProto.spacing;
			text: model.lcn + ". " + model.text;
			color: channelDelegateProto.activeFocus ? colorTheme.focusedTextColor : colorTheme.accentTextColor;
			font.bold: true;
		}

		Item {
			anchors.top: channelLabelText.bottom;
			anchors.left: logoBg.right;
			anchors.right: parent.right;
			anchors.bottom: durationText.top;
			anchors.leftMargin: channelDelegateProto.spacing;
			anchors.rightMargin: channelDelegateProto.spacing;

			SmallText {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.right: parent.right;
				text: model.program.title;
				color: channelDelegateProto.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
			}
		}

		SmallText {
			id: durationText;
			anchors.left: logoBg.right;
			anchors.bottom: parent.bottom;
			anchors.margins: channelDelegateProto.spacing;
			text: model.program.start + (model.program.start ? " - " : "") + model.program.stop;
			color: channelDelegateProto.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		}

		Item {
			height: 3;
			anchors.left: durationText.right;
			anchors.right: parent.right;
			anchors.verticalCenter: durationText.verticalCenter;
			anchors.leftMargin: channelDelegateProto.spacing;
			anchors.rightMargin: channelDelegateProto.spacing;

			Rectangle {
				id: programProgress;
				width: model.program.progress * parent.width;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				color: colorTheme.accentColor;
			}
		}
	}

	Rectangle {
		id: showEpgItem;
		height: parent.height;
		width: 50;
		anchors.right: parent.right;
		visible: model.program.startTime && parent.activeFocus;
		color: blinkRect.color;

		Image {
			anchors.centerIn: parent;
			source: colorTheme.res + "b_epg.png";
		}
	}

	Timer {
		id: toggleTimer;
		interval: 300;
		repeat: false;

		onTriggered: { channelDelegateProto.toggled = false }
	}

	onSelectPressed: {
		this.blinck()
		event.accepted = false
	}

	onClicked: { this.blinck() }

	blinck: {
		if (this.mouseX >= this.width - showEpgItem.width) {
			this.epgCalled()
		} else {
			this.toggled = true
			toggleTimer.restart()
		}
	}

	Behavior on opacity { Animation { duration: 300; } }
}
