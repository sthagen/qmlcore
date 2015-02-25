Object {
	signal triggered;

	property int interval: 1000;
	property bool repeat;
	property bool running;
	property bool triggeredOnStart;

	restart:	{ this._restart(); this.running = true; }
	start:		{ this.running = true; }
	stop:		{ this.running = false; }
}
