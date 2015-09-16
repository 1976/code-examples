/*
MAIN
THIS CLASS CONTROLS PRELOADING AND 
GENERAL APP SETUP NOTE: IN ALL CLASSES YOU WILL FIND LOCAL METHOD VARS 
CALLED "CONTEXT" THIS VARIABLE IS USED TO PASS A REFERENCE TO THE CLASS
CONTEXT INTO METHODS WHERE THIS WOULD REFER TO WINDOW OR JQUERY ECT.
*/
(function(window){

	function App(){		
		this._imageArray = [ ];

		this._activeNavButton;
		this._deviceType;
		this._isTablet;
		this._data;
		this._rootViewController;
		this._viewControllers = [];
		this._modalViewController;
		this._dateTitle;
		this._soundIsPlaying;
		this._backgroundMusic;
		this._userPausedMusic;
		
		this._history;
		this._state;
		
		this.setCurrentViewController = function(id){	
			
		};
		
		this.onSoundBtnClick = function(e){
			
			if(this._modalViewController){
				if(this._modalViewController instanceof VideoViewController){
					return;
				}
			}

			if( this._soundIsPlaying ){
				this._userPausedMusic = true;
				this.pauseBgMusic();
			}else{
				this._userPausedMusic = false;
				this.playBgMusic();
			}
			
		}
		
		this.playBgMusic = function(){
			if(this._modalViewController){
				if(this._modalViewController instanceof VideoViewController){
					return;
				}
			}

			$("header .share-Sound-button").addClass("share-Sound-button-active");
			$("footer .share-Sound-button").addClass("share-Sound-button-active");
			
			if(!this._backgroundMusic){
				this._backgroundMusic = createjs.Sound.play("bgMusic",null, 0, 0, 1000000, 0.50);
			}else{
				this._backgroundMusic.play("bgMusic",null, 0, 0, 1000000, 0.50);
			}
			
			this._soundIsPlaying = true;
		}
		
		this.pauseBgMusic = function(){
			$("header .share-Sound-button").removeClass("share-Sound-button-active");
			$("footer .share-Sound-button").removeClass("share-Sound-button-active");
			
			if( this._backgroundMusic ){
				this._backgroundMusic.stop();
			}
			
			this._soundIsPlaying = false;
		}
		
		this.onWindowBlurFocus = function(e){
			if(e.type == "focus"){
				if(!this._soundIsPlaying && !this._userPausedMusic){
					this.playBgMusic();
				}
			}else{
				if(this._soundIsPlaying){
					this.pauseBgMusic();
				}
			}
		}

			
		this.onWindowResize = function(e){
			if(this._modalViewController){
				this._modalViewController.onWindowResize();
			}
			
			if( this._rootViewController ){
				this._rootViewController.onWindowResize();
			}
		};
	
		this.onLoadSetupComplete = function(e){
			var context = this;
			$.getScript("http://code.createjs.com/preloadjs-0.4.1.min.js", function(){
				$.getScript("http://code.createjs.com/easeljs-0.7.0.min.js", function(){
					$.getScript("http://code.createjs.com/soundjs-0.5.2.min.js", function(){
						context.loadPageData()
					});
				});
			});
		};
		
		this.loadPageData = function(){
			var context = this;
			
			var pageType;
			
			if( this._deviceType == "phone"){
				pageType = "mobile";
				$("body").append('<div class="mobile-landscape"><img src="img/content/mobile/rotate-device.png" alt="Please rotated device to view site in portrait mode"/></div>');
			}else{
				pageType = "desktop";
			}
			
			$(".wrapper").addClass(pageType);
			
			this.loadImages();
			
		};
		
		this.loadImages = function(){
			var context = this;
			
			var images = $("body").find("img");
			var i;
		
			for(i = 0; i < images.length; i++){
				this._imageArray.push($(images[i]).attr("src"));
			}
			
			var bgImages = [ ];
			var imageUrl;
			
			$("*:not(span,p,h1,h2,h3,h4,h5)").filter(function(){
				if( $(this).css("background-image") != "none" ){
					imageUrl = $(this).css("background-image").replace("url(", "");
					imageUrl = imageUrl.replace(")", "");
					imageUrl = imageUrl.replace('"', "");
					imageUrl = imageUrl.replace('"', "");
				
					if( imageUrl.search(".png") == -1 && imageUrl.search(".jpg") == -1 && imageUrl.search(".gif") == -1 ){
						
					}else{
						if(  imageUrl.search("base64") == -1 ){
							if( context._imageArray.indexOf(imageUrl) == -1 ){
								context._imageArray.push(imageUrl);
							}
						}
					}
				}
			});
			
			if(this._deviceType != "phone"){
				for(i = 0; i < this._data.scares.length; i++){
					var animation = this._data.scares[i];
										
					var soundEffectURL = "sound/" + animation.soundEffect;
					this._imageArray.push({id:soundEffectURL, src:soundEffectURL });
					
					for( var a = 1; a <= animation.totalFrames; a++ ){
						imageUrl = "img/content/desktop/scares/" + animation.scare + "/" + a + ".jpg";
						this._imageArray.push({id:imageUrl, src:imageUrl});
					}
					
				}
			
				for(i = 0; i < this._data.tumblr.animation.length; i++){
					var animation = this._data.tumblr.animation[i];
					var textURL = "img/content/desktop/tumblr/text/" + animation.text;
					this._imageArray.push({id:textURL, src:textURL});
				}
				
				for(i = 1; i <= this._data.story.intro.totalFrames; i++){
					imageUrl = "img/content/desktop/story/intro/" + i + ".jpg";
					this._imageArray.push({id:imageUrl, src:imageUrl});
				}
				
				for(i = 1; i <= this._data.story.bg.totalFrames; i++){
					imageUrl = "img/content/desktop/story/bg/" + i + ".jpg";
					this._imageArray.push({id:imageUrl, src:imageUrl});
				}

			}
			
			this._loader = new createjs.LoadQueue(false);
			
			this._loader.addEventListener("complete",function(e){ context.onImageLoadComplete(e) });
			this._loader.addEventListener("progress",function(e){ context.onImageLoadProgress(e) });
			
			createjs.Sound.alternateExtensions = ["mp3"];
			createjs.Sound.alternateExtensions = ["m4a"];
			
			
			this._loader.installPlugin(createjs.Sound);
			
			var bgMusic = {
				id:"bgMusic",
				src:"sound/bg-music.mp3"
			}
			
			this._imageArray.push(bgMusic);
			

			this._loader.loadManifest(this._imageArray);
			//this._preloadTimer = setInterval(function(){ context.onPreloadTimerTick(); }, this._preloadTime / 100);
			this._hasLoadStart = true;
		};
				
		this.loadSetup = function(){
			var context = this;
						
			$.ajax({
				type:"GET",
				url: "api/data/index.php",
				dataType:"json",
				success: function(data){	
					context._data = data[0];
					context.onLoadSetupComplete();			
				},
				error: function(jqXHR, textStatus, errorMessage) {
					if( window.console ) console.log("error", errorMessage, textStatus, jqXHR);
				}
			});
		};
		
		this.resetActiveNavButton = function(){
			if( this._activeNavButton ){
				this._activeNavButton.removeClass("nav-button-selected");
				this._activeNavButton = null;
			}
		};
		
		this.onTitleButtonClick = function(e){
			e.preventDefault();
			
			/*this.resetActiveNavButton();
			
			if(this._modalViewController) {
				this._modalViewController.exit();
				
			}*/
			
			this._history.pushState({state:"root"}, "", "?p=root");
		};
		
		this.onModalNavigationEvent = function(e){
			
			this._history.pushState({state:e.state}, "", e.attr);
		}
		
		
		this.setActivePage = function(urlVars){
			var modal = $("#root .modal");
			var containerID = this._state.data.state;
			var model;
			var pageID;
			var context = this;
			
			if( this._modalViewController){
				this._modalViewController.pause();
				
				$(this._modalViewController).off("exitComplete");
				$(this._modalViewController).off("introComplete");
				$(this._modalViewController).off("navigationEvent");
				
				this._modalViewController.dealloc();
				this._modalViewController = null;
			}
						
			modal.append('<div id="' + containerID + '" class="modal-page"></div>');
						
			switch(containerID){
				case "story":
					viewController = new StoryViewController();
					model = this._data.story;
					pageID = 2;
					break;
				case "video":
					viewController = new VideoViewController();
					model = this._data.video;
					pageID = 3;
					break;
				case "tumblr":
					viewController = new TumblrViewController();
	
					model = this._data.tumblr;
					pageID = 5;
					break;
				case "gallery":
					viewController = new GalleryViewController();
					model = this._data.gallery;
					pageID = 4;
					break;
			}
			
			if(model){
				model.loader = this._loader;
			}
			
			viewController.init("#root .modal", model, this._deviceType);
			
			this._viewControllers.push(viewController);
			
			this._modalViewController = viewController;
			
			$(this._modalViewController).on("exitComplete", function(e){ context.onModalExitComplete(e); });
			$(this._modalViewController).on("navigationEvent", function(e){ context.onModalNavigationEvent(e); });
			$(this._modalViewController).on("introComplete", function(e){ context.onModelIntroComplete(e); });
			$(this._modalViewController).on("closeButtonClick", function(e){ context.onModalCloseButtonClick(e); });
			$(this._modalViewController).on("PauseBGSound", function(e){ context.pauseBgMusic(); });
						
			if( urlVars.length > 1){
						this._modalViewController.updateOnNavigationEvent(urlVars);
					}	
			
			this._modalViewController.intro();
			
			if( containerID == "video" ){
				this.pauseBgMusic();
			}else{
				if( !this._userPausedMusic && !this._soundIsPlaying ){
					this.playBgMusic();
				}
			}
		};
		
		
		this.onWindowStateChange = function(e){
			var vars;
			
			if( this._state ){
				if(this._state.data.state == this._history.getState().data.state){
					
					this._state = this._history.getState();
					
					vars = this.getURLVars();
					
					if( vars.length > 1){
						this._modalViewController.updateOnNavigationEvent(vars);
					}
										
					return;
				};
			}
						
			this._state = this._history.getState();
			
			vars = this.getURLVars();
						
			if( this._state.data.state == undefined ){
				
				if( this.getURLVarByID("p") ){
					this._state.data.state = this.getURLVarByID("p").val;
				}else{
					console.log("undefined state killing nav");
				}
			}
			
			this.resetActiveNavButton();
			
			
			if( this._state.data.state == undefined || this._state.data.state == "root"){
				if(this._modalViewController) {
					this._modalViewController.exit();
				}
			}else{
				this.setActivePage(vars);
				this.setActiveButton();
				
				

			}
				
		};
		
		this.setActiveButton = function(){
			var button;
			var context = this;
						
			$("header nav ul li").each(function(){
				if($(this).attr("data-id") == context._state.data.state){
					button = $(this);
				}
			});
			
			if( button ){
				this._activeNavButton = button;
				this._activeNavButton.addClass("nav-button-selected");

			}
		}

		
		this.onNavButtonClick = function(e){
			e.preventDefault();
			
			var button = $(e.currentTarget);
			
			if(button.attr("data-id") == "tickets"){
				console.log(ga());
				ga('send', 'event', 'tickets', 'get tickets clicked', 'home page');
				window.open("http://www.fandango.com/thevisit2015_180875/movietimes", "_blank");
				return;
			}
			
			if(button.is(this._activeNavButton)) return;
			
			var containerID = button.attr("data-id");
			
			switch(containerID){
				case "story":
					pageID = "story";
					break;
				case "video":
					pageID = "video";
					break;
				case "tumblr":
					pageID = "tumblr";
					break;
				case "gallery":
					pageID = "gallery";
					break;
			}
			
			this._history.pushState({state:pageID}, "", "?p=" + pageID);
			
			
			
			/*this.resetActiveNavButton();
			
			if( this._modalViewController){
				this._modalViewController.pause();
				
				$(this._modalViewController).off("exitComplete");
				$(this._modalViewController).off("introComplete");
				
				this._modalViewController.dealloc();
				this._modalViewController = null;
			}
			
			this._activeNavButton = button;
			this._activeNavButton.addClass("nav-button-selected");
			
			var viewController;
			var context = this;
			
			var modal = $("#root .modal");
			var containerID = this._activeNavButton.attr("data-id");
			var model;
			var pageID;
						
			modal.append('<div id="' + containerID + '" class="modal-page"></div>');
						
			switch(containerID){
				case "story":
					viewController = new StoryViewController();
					model = this._data.story;
					pageID = 2;
					break;
				case "video":
					viewController = new VideoViewController();
					model = this._data.video;
					pageID = 3;
					break;
				case "tumblr":
					viewController = new TumblrViewController();
					model = this._data.tumblr;
					pageID = 5;
					break;
				case "gallery":
					viewController = new GalleryViewController();
					model = this._data.gallery;
					pageID = 4;
					break;
			}
			
			if(model){
				model.loader = this._loader;
			}
			
			viewController.init("#root .modal", model, this._deviceType);
			
			this._viewControllers.push(viewController);
			
			this._modalViewController = viewController;
			
			$(this._modalViewController).on("exitComplete", function(e){ context.onModalExitComplete(e); });
			$(this._modalViewController).on("introComplete", function(e){ context.onModelIntroComplete(e); });
			$(this._modalViewController).on("closeButtonClick", function(e){ context.onModalCloseButtonClick(e); });
			$(this._modalViewController).on("PauseBGSound", function(e){ context.pauseBgMusic(); });
			
			this._modalViewController.intro();
			
			if( containerID == "video" ){
				this.pauseBgMusic();
			}else{
				if( !this._userPausedMusic && !this._soundIsPlaying ){
					this.playBgMusic();
				}
			}
			
			this._history.pushState({state:pageID}, "", "?p=" + pageID);*/
		}
		
		this.onModalCloseButtonClick = function(){
			if( this._modalViewController ){
				this.resetActiveNavButton();
				this._modalViewController.exit();
			}
		}
		
		this.onModalExitComplete = function(e){
			if( !this._activeNavButton ){
				this.popViewControllers(true);
				
				if( !this._userPausedMusic && !this._soundIsPlaying ){
					this.playBgMusic();
				}
			}
		}
		
		this.onModelIntroComplete = function(e){
			if(this._viewControllers.length > 1){
				this.popViewControllers(false);
			}
			
		}
		
		this.popViewControllers = function(removeAll){
			var totalLeft = 1;
			if(removeAll) totalLeft = 0;
						
			while(this._viewControllers.length > totalLeft){
				var vc = this._viewControllers[0];
				$(vc).off();
				this._viewControllers.shift();
				//vc.dealloc();
			}
		}

		this.playSoundWithID = function(e){

			var soundID = e.sound;
			
			createjs.Sound.play(soundID);
		}
		
		this.playVideoWithID = function(e){
			var videoID = e.videoID;
			
			this._videoViewController.playVideoWithID(videoID);
			this._videoViewController.intro();
		}
		
		this.onVideoExitComplete = function(e){
			$(this._videoViewController).off("exitComplete");
			this._rootViewController.intro();
		}
		
		this.onPreloaderExit = function(){
			$(".preloader").remove();
		}
		
		this.getReleaseTitle = function(){
			var currentDate = new Date();
			var releaseDate = new Date("2015/9/11");
			
			if( currentDate.getTime() >= releaseDate.getTime() ){
				this._dateTitle = "NOW PLAYING";
			}else{
				if( currentDate.getMonth() == releaseDate.getMonth() && currentDate.getDate() == (releaseDate.getDate() - 1)){
					this._dateTitle = "IN THEATERS TOMORROW";
				}else if(currentDate.getMonth() == releaseDate.getMonth() && currentDate.getDate() > (releaseDate.getDate() - 5) && currentDate.getDate() < (releaseDate.getDate() - 1)){
					this._dateTitle = "IN THEATERS FRIDAY";
				}else{
					this._dateTitle = "IN THEATERS SEPTEMBER";
				}
			}
			
			return this._dateTitle;

		}
		
	}
	
	App.prototype = {
		init:function(deviceType, isTablet){
			this._deviceType = deviceType;
			this._isTablet = isTablet;
			
			var context = this;
			
			var oldIE = false;
			
			if ($('html').is('.ie6, .ie7, .ie8')) {
				oldIE = true;
			}
			
			if(oldIE){
				$(".wrapper").remove();
				
				var context = this;
				
				$("body").load("partials/ood.html", function(){
					$(".title h2").html(context.getReleaseTitle());
				});
				return;
			}
			
			 videojs.options.flash.swf = "js/vendor/videojs/video-js.swf";
			
			this.loadSetup();	
			
			this._history = window.History;
			//this._state = this._history.getState();
			
			this._history.Adapter.bind( window, "statechange", function(e){ context.onWindowStateChange(e)});
		},
		onImageLoadComplete:function(e){
			var context = this;
						
			$("header .title-treatment h2").html(this.getReleaseTitle());
			
			this._data.root.loader = this._loader;
			
			this._rootViewController = new RootViewController();
			this._rootViewController.init("#root", this._data.root, this._deviceType);
			this._rootViewController.setTitle(this._dateTitle);
			
			$(window).on("resize", function(e){ context.onWindowResize(e)});
			
			$(window).on("blur focus", function(e){ context.onWindowBlurFocus(e); });
			
			$("header nav ul li").each(function(){
				$(this).on("click", function(e){ context.onNavButtonClick(e); });
			});
			
			$("header .title-treatment").on("click", function(e){ context.onTitleButtonClick(e); });
			$("header .share-Sound-button").on("click", function(e){ context.onSoundBtnClick(e); });
			$("footer .share-Sound-button").on("click", function(e){ context.onSoundBtnClick(e); });
			
			this.onWindowStateChange();
						
			TweenMax.to($(".preloader"), 0.5, {autoAlpha:0, delay: 1, onComplete:function(){ context.onPreloaderExit() }});	
	
			if( this._deviceType != "phone" && !this._isTablet){
				this.playBgMusic();
			}
		},
		onLoadCompleteReady:function(){
				
		},
		onImageLoadProgress:function(e){			
			var percentage = Math.round(e.loaded * 100);
						
			$(".preloader p").html(percentage);
		},
		getURLVars:function(){
			var vars = [];
			var urlVarStr = this._state.url.split("?");
			
			if( urlVarStr[1] ){
				var tempStr = urlVarStr[1].split("&");
				
				for( var i = 0; i < tempStr.length; i++ ){
					var tempVar = tempStr[i].split("=");
					var name = tempVar[0];
					var val = tempVar[1];
					var obj = {
						id:name,
						val:val
					}
					vars.push(obj);
				}
			}
			
			return vars;
		},
		getURLVarByID:function(id){
			var varObj;
			
			var vars = this.getURLVars();
			for(var i= 0; i < vars.length; i++){
				var obj = vars[i];
				if(obj.id == id){
					varObj = obj;
					break;
				}
			}
			
			return varObj;
		}
	}

	window.App = App;
}(window));
