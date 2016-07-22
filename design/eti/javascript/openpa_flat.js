(function($){
    "use strict";

    var globalDeferred = $.Deferred();
    $(window).bind('load',function(){
        // after loading all the scripts
        globalDeferred.resolve();
    });

    // waypoints helper functions
    $.fn.waypointInit = function(classN,offset,delay,inv){
        return $(this).waypoint(function(direction){
            var current = $(this);
            if(direction === 'down'){
                if(delay){
                    setTimeout(function(){
                        current.addClass(classN);
                    },delay);
                }
                else{
                    current.addClass(classN);
                }
            }else{
                if(inv == true){
                    current.removeClass(classN);
                }
            }
        },{ offset : offset })
    };

    // synchronise
    $.fn.waypointSynchronise = function (config) {
        var element = $(this);

        function addClassToElem(el, eq) {
            el.eq(eq).addClass(config.classN);
        }

        element.closest(config.container).waypoint(function (direction) {
            element.each(function (i) {
                if (direction === 'down') {

                    if (config.globalDelay != undefined) {
                        setTimeout(function () {
                            setTimeout(function () {
                                addClassToElem(element, i);
                            }, i * config.delay);
                        }, config.globalDelay);
                    } else {
                        setTimeout(function () {
                            addClassToElem(element, i)
                        }, i * config.delay);
                    }

                } else {

                    if (config.inv) {
                        setTimeout(function () {
                            element.eq(i).removeClass(config.classN);
                        }, i * config.delay);
                    }

                }
            });
        }, { offset: config.offset });
        return element;
    };

    globalDeferred.done(function () {

        // go to top button
        (function () {
            $('#go_to_top').waypointInit('animate_horizontal_finished', '0px', 0, true);
            $('#go_to_top').on('click', function () {
                $('html,body').animate({
                    scrollTop: 0
                }, 500);
            });
        })();

        // ie9 placeholder
        (function () {
            if ($('html').hasClass('ie9')) {
                $('input[placeholder]').each(function () {
                    $(this).val($(this).attr('placeholder'));
                    var v = $(this).val();
                    $(this).on('focus',function () {
                        if ($(this).val() === v) {
                            $(this).val("");
                        }
                    }).on("blur", function () {
                            if ($(this).val() == "") {
                                $(this).val(v);
                            }
                        });
                });

            }
        })();

        (function(){

            // current menu
            $('[role="navigation"] ul > li:not(.context-menu) > a').each( function(e){
                var node = $(this).data( 'contentnode' );
                if (node) {
                    var href = $(this).attr( 'href' );
                    if ( UiContext == 'browse' ) {
                        href = '/content/browse/' + node;
                    }
                    $(this).attr( 'href', href );
                    var self = $(this);
                    $.each(PathArray, function(i,v){
                        if (v==node){
                            self.closest('li').addClass( 'current' );
                        }
                    });
                }
            });

            // tooltip
            $('.has_tooltip').tooltip();

            //preview
            $('[data-load-remote]').on('click',function(e) {
                e.preventDefault();
                var $this = $(this);
                $($this.data('remote-target')).html('<em>Loading...</em>');
                var remote = $this.data('load-remote');
                if(remote) {
                    $($this.data('remote-target')).load(remote);
                }
            });


        })();

        // responsive menu
        window.rmenu = function () {

            var menuWrap = $('[role="navigation"]'),
                menu = $('.main_menu'),
                button = $('#menu_button');

            function orientationChange() {
                button.on('click tap', function () {
                    menuWrap.stop().slideToggle();
                    $(this).toggleClass('active');
                });
            }

            orientationChange();

            $(window).on('resize', orientationChange);

        };
        rmenu();

        $('.side_menu').on('click', 'span', function (e) {
            if ($(this).closest('li').children('ul').length) {
                $(this).closest('li').toggleClass('active');
                //$(this).closest('li').next().slideToggle();
                e.preventDefault();
            }
        });

        (function () {
            $('#go_to_top').waypointInit('animate_horizontal_finished', '0px', 0, true);
            $('#go_to_top').on('click', function () {
                $('html,body').animate({
                    scrollTop: 0
                }, 500);
            });
        })();

        (function () {
            $('.sw_button').on('click', function () {
                $(this).parent().toggleClass('opened').siblings().removeClass('opened');
            });
        })();

    });
})(jQuery);