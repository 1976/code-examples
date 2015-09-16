/*GENERIC  VIEW CONTROLLER*/
(function(window){
	RootViewController.prototype = new BaseViewController();
	RootViewController.prototype.constructor = RootViewController;
	
	function RootViewController(){
		this._isShowingScare;
		this._textContainer;
		
		
		this.onTextContainerLeave = function(){
			this._isShowingScare = false;
			this._textContainer.off("mouseleave");
		}
		
		this.showActiveScare = function(){
			
			if(this._isShowingScare) return;
			this._isShowingScare = true;
			
			var context = this;
			
			var html = $('<div class="scare"></div>');
			this._view.append(html);
			
			var scare = new ScareViewController();
			var scareCopy = jQuery.extend(true, {}, this._model.scare);
			scareCopy.loader = this._model.loader;
			scare.init(html, scareCopy, this._deviceType);
			$(scare).on("introComplete", function(){
				//context._isShowingScare = false;
				context._textContainer.on("mouseleave", function(){ context.onTextContainerLeave() });
			});
			scare.intro();
			
		}
	}
	
	RootViewController.prototype.init = function(target, model, deviceType){
		this.baseSetup(target, model, deviceType);
		
		var context = this;
		
		if(!Modernizr.cssanimations){
			var swing = $(this._view.find(".root-swing"));
			swing.css("-ms-transform", "rotate(2deg)");
			TweenMax.to(swing, 3, {rotation:-2, repeat:-1, yoyo:true, ease:Sine.easeInOut});
		}
		
		
		this._textContainer = $(this._view.find(".root-title"));
		
		if( this._deviceType != "phone"){
			this._textContainer.on("click", function(){ context.showActiveScare() });
			this._textContainer.on("mouseenter", function(){ context.showActiveScare() });
		}
			
		this.onWindowResize();
		
		
	}
	
	RootViewController.prototype.setTitle = function(){
		
	}
	
	RootViewController.prototype.onWindowResize = function(){
		var swing = $(this._view.find(".root-swing"));
		var bg = $(this._view.find(".bg"));
		
		var bottomPadding = 130;
		
		if(this._deviceType == "desktop") bottomPadding = 100
		
		var swingHeight = bg.height() - bottomPadding;
		
		if( swingHeight < 584 && this._deviceType == "desktop" ) swingHeight = 584;
		
		var scale = swingHeight / 584;
		
		var swingWidth = 148 * scale;
		
		if( this._deviceType == "desktop"){
			swing.css({ width: swingWidth, height: swingHeight, marginLeft: -swingWidth / 2, bottom: 100});
		} else {
			swing.css({ width: swingWidth, height: swingHeight, marginLeft: 50, bottom: 110});
		}
	}
	
	window.RootViewController = RootViewController;
}(window));