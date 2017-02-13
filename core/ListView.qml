BaseView {
	property enum orientation { Vertical, Horizontal };

	function move(dx, dy) {
		var horizontal = this.orientation == this.Horizontal
		var x, y
		if (horizontal && this.contentWidth > this.width) {
			x = this.contentX + dx
			if (x < 0)
				x = 0
			else if (x > this.contentWidth - this.width)
				x = this.contentWidth - this.width
			this.contentX = x
		} else if (!horizontal && this.contentHeight > this.height) {
			y = this.contentY + dy
			if (y < 0)
				y = 0
			else if (y > this.contentHeight - this.height)
				y = this.contentHeight - this.height
			this.contentY = y
		}
	}

	function positionViewAtIndex(idx) {
		var cx = this.contentX, cy = this.contentY
		var itemBox = this.getItemPosition(idx)
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height
		var horizontal = this.orientation == this.Horizontal
		var center = this.positionMode === this.Center

		if (horizontal) {
			var atCenter = x - w / 2 + iw / 2
			if (center && this.contentWidth > w)
				this.contentX = atCenter < 0 ? 0 : x > this.contentWidth - w / 2 - iw / 2 ? this.contentWidth - w : atCenter
			else if (iw > w)
				this.contentX = atCenter
			else if (x - cx < 0)
				this.contentX = x
			else if (x - cx + iw > w)
				this.contentX = x + iw - w
		} else {
			var atCenter = y - h / 2 + ih / 2
			if (center && this.contentHeight > h)
				this.contentY = atCenter < 0 ? 0 : y > this.contentHeight - h / 2 - ih / 2 ? this.contentHeight - h : atCenter
			else if (ih > h)
				this.contentY = atCenter
			else if (y - cy < 0)
				this.contentY = y
			else if (y - cy + ih > h)
				this.contentY = y + ih - h
		}
	}


	onKeyPressed: {
		if (!this.handleNavigationKeys) {
			event.accepted = false;
			return false;
		}

		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (key == 'Left') {
				--this.currentIndex;
				event.accepted = true;
				return true;
			} else if (key == 'Right') {
				++this.currentIndex;
				event.accepted = true;
				return true;
			}
		} else {
			if (key == 'Up') {
				if (!this.currentIndex && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				}
				--this.currentIndex;
				return true;
			} else if (key == 'Down') {
				if (this.currentIndex == this.count - 1 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				}
				++this.currentIndex;
				event.accepted = true;
				return true;
			}
		}
	}

	function getItemPosition(idx) {
		var items = this._items
		var item = items[idx]
		if (!item) {
			var x = 0, y = 0, w = 0, h = 0
			for(var i = idx; i >= 0; --i) {
				if (items[i]) {
					item = items[i]
					x = item.viewX + item.x
					y = item.viewY + item.y
					w = item.width
					h = item.height
					break
				}
			}
			var missing = idx - i
			if (missing > 0) {
				x += missing * (w + this.spacing)
				y += missing * (h + this.spacing)
			}
			return [x, y, w, h]
		}
		else
			return [item.viewX + item.x, item.viewY + item.y, item.width, item.height]
	}

	function indexAt(x, y) {
		var items = this._items
		x += this.contentX
		y += this.contentY
		if (this.orientation == ListView.Horizontal) {
			for (var i = 0; i < items.length; ++i) {
				var item = items[i]
				if (!item)
					continue
				var vx = item.viewX
				if (x >= vx && x < vx + item.width)
					return i
			}
		} else {
			for (var i = 0; i < items.length; ++i) {
				var item = items[i]
				if (!item)
					continue
				var vy = item.viewY
				if (y >= vy && y < vy + item.height)
					return i
			}
		}
		return -1
	}

	function _layout() {
		var model = this.model;
		if (!model) {
			this.layoutFinished()
			return
		}

		this.count = model.count

		if (!this.recursiveVisible) {
			this.layoutFinished()
			return
		}

		var horizontal = this.orientation === this.Horizontal

		var items = this._items
		var n = items.length
		if (!n) {
			this.layoutFinished()
			return
		}

		var w = this.width, h = this.height
		//log("layout " + n + " into " + w + "x" + h)
		var created = false
		var p = 0
		var c = horizontal? this.content.x: this.content.y
		var size = horizontal? w: h
		var maxW = 0, maxH = 0

		var itemsCount = 0
		for(var i = 0; i < n && (itemsCount == 0 || p + c < size); ++i) {
			var item = items[i]

			if (!item) {
				if (p + c >= size && itemsCount > 0)
					break
				item = this._createDelegate(i)
				created = true
			}

			++itemsCount

			var s = (horizontal? item.width: item.height)
			var visible = (p + c + s >= 0 && p + c < size)

			if (item.x + item.width > maxW)
				maxW = item.width + item.x
			if (item.y + item.height > maxH)
				maxH = item.height + item.y

			if (horizontal)
				item.viewX = p
			else
				item.viewY = p

			if (this.currentIndex == i) {
				this.focusChild(item)
				if (this.contentFollowsCurrentItem)
					this.positionViewAtIndex(i)
			}

			item.visibleInView = visible
			p += s + this.spacing
		}
		for( ;i < n; ++i) {
			var item = items[i]
			if (item)
				item.visibleInView = false
		}
		if (p > 0)
			p -= this.spacing;

		if (itemsCount)
			p *= items.length / itemsCount

		if (horizontal) {
			this.content.width = p
			this.content.height = maxH
			this.contentWidth = p
			this.contentHeight = maxH
		} else {
			this.content.width = maxW
			this.content.height = p
			this.contentWidth = maxW
			this.contentHeight = p
		}
		this.layoutFinished()
		if (created)
			this._context._complete()
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		var item = _globals.core.BaseView.prototype._createDelegate.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		if (this.orientation === this.Horizontal)
			item.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		else
			item.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		return item
	}

	onOrientationChanged: { this._delayedLayout.schedule() }
}
