var imgvwr = {};

(function(lib) {

    var map_registry = {};

    var base_options = {
        imageServiceBaseUrl: "http://images.ala.org.au",
        auxDataUrl: '',
        initialZoom: 2
    };

    lib.viewImage = function(targetDiv, imageId, options) {
        var mergedOptions = mergeOptions(options, targetDiv, imageId);
        initViewer(mergedOptions);
    };

    lib.resizeViewer = function(targetDiv) {
        var target = getTarget(targetDiv);
        map_registry[target].invalidateSize();
    };

    /** Allows the target div to be specified as a selector or jquery object */
    function getTarget(target) {
        return $(target).get(0);
    }

    function mergeOptions(userOptions, targetDiv, imageId) {
        var mergedOptions = {
            target:  targetDiv,
            imageId: imageId
        };

        $.extend(mergedOptions, base_options, userOptions);

        return mergedOptions;
    }

    function initViewer(opts) {
        $.ajax( {
            dataType: 'jsonp',
            url: opts.imageServiceBaseUrl + "/ws/getImageInfo/" + opts.imageId,
            crossDomain: true
        }).done(function(image) {

            if (image.success) {
                _createViewer(opts, image);
            }
        });
    }

    function _createViewer(opts, image) {

        var maxZoom = image.tileZoomLevels ? image.tileZoomLevels - 1 : 0;

        var imageScaleFactor =  Math.pow(2, maxZoom);

        var centerx = image.width / 2 / imageScaleFactor;
        var centery = image.height / 2 / imageScaleFactor;

        var p1 = L.latLng(image.height / imageScaleFactor, 0);
        var p2 = L.latLng(0, image.width / imageScaleFactor);
        var bounds = new L.latLngBounds(p1, p2);

        var measureControlOpts = false;

        if (image.mmPerPixel) {
            measureControlOpts = {
                mmPerPixel: image.mmPerPixel,
                imageScaleFactor: imageScaleFactor,
                imageWidth: image.width,
                imageHeight: image.height,
                hideCalibration: true
            };
        }

        var target = getTarget(opts.target);

        // Check if this element has already been initialized as a leaflet viewer
        if (map_registry[target]) {
            // if so, we need to uninitialize it
            map_registry[target].remove();
            delete map_registry[target];
        }

        var viewer = L.map(target, {
            fullscreenControl: true,
            measureControl: measureControlOpts,
            minZoom: 2,
            maxZoom: maxZoom,
            zoom: opts.initialZoom <= 0 ? maxZoom : opts.initialZoom,
            center:new L.LatLng(centery, centerx),
            crs: L.CRS.Simple
        });

        map_registry[target] = viewer;

        var urlMask = image.tileUrlPattern;
        L.tileLayer(urlMask, {
            attribution: '',
            maxNativeZoom: maxZoom,
            continuousWorld: true,
            tms: true,
            noWrap: true,
            bounds: bounds
        }).addTo(viewer);

        var ImageInfoControl = L.Control.extend( {

            options: {
                position: "bottomleft",
                title: 'Image details'
            },
            onAdd: function (map) {
                var container = L.DomUtil.create("div", "leaflet-bar");
                var detailsUrl = opts.imageServiceBaseUrl + "/image/details/" + opts.imageId;
                $(container).html("<a href='" + detailsUrl + "' title='" + this.options.title + "'><span class='fa fa-external-link'></span></a>");
                return container;
            }
        });
        viewer.addControl(new ImageInfoControl());

        if (opts.auxDataUrl) {

            var AuxInfoControl = L.Control.extend({

                options: {
                    position: "topleft",
                    title: 'Auxiliary data'
                },
                onAdd: function (map) {
                    var container = L.DomUtil.create("div", "leaflet-bar");
                    $(container).html("<a id='btnImageAuxInfo' href='#'><span class='fa fa-info'></span></a>");
                    $(container).find("#btnImageAuxInfo").click(function (e) {
                        e.preventDefault();
                        $.ajax( {
                            dataType: 'jsonp',
                            url: opts.auxDataUrl,
                            crossDomain: true
                        }).done(function(auxdata) {
                            var body = "";
                            if (auxdata.data) {
                                body = '<table class="table table-condensed table-striped table-bordered">';
                                for (var key in auxdata.data) {
                                    body += '<tr><td>' + key + '</td><td>' + auxdata.data[key] + '</td></tr>';
                                }
                                body += '</table>';
                            }

                            if (auxdata.link && auxdata.linkText) {
                                body += '<div><a href="' + auxdata.link + '">' + auxdata.linkText + '</a>';
                            } else if (auxdata.link) {
                                body += '<div><a href="' + auxdata.link + '">' + auxdata.link + '</a>';
                            }

                            lib.showModal({
                                title: auxdata.title ? auxdata.title : "Image " + opts.imageId,
                                content: body,
                                width: 800
                            });
                        });
                    });
                    return container;
                }
            });

            viewer.addControl(new AuxInfoControl());
        }
    }

    lib.showModal = function(options) {

        var opts = {
            backdrop: options.backdrop ? options.backdrop : true,
            keyboard: options.keyboard ? options.keyboard: true,
            url: options.url ? options.url : false,
            id: options.id ? options.id : 'modal_element_id',
            height: options.height ? options.height : 500,
            width: options.width ? options.width : 600,
            title: options.title ? options.title : 'Modal Title',
            hideHeader: options.hideHeader ? options.hideHeader : false,
            onClose: options.onClose ? options.onClose : null,
            onShown: options.onShown ? options.onShown : null,
            content: options.content
        };

        var html = "<div id='" + opts.id + "' class='modal hide' role='dialog' aria-labelledby='modal_label_" + opts.id + "' aria-hidden='true' style='width: " + opts.width + "px; margin-left: -" + opts.width / 2 + "px;overflow: hidden'>";
        var initialContent = opts.content ? opts.content : "Loading...";
        if (!opts.hideHeader) {
            html += "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>x</button><h3 id='modal_label_" + opts.id + "'>" + opts.title + "</h3></div>";
        }
        html += "<div class='modal-body' style='max-height: " + opts.height + "px'>" + initialContent + "</div></div>";

        $("body").append(html);

        var selector = "#" + opts.id;

        $(selector).on("hidden", function() {
            if (opts.onClose) {
                opts.onClose();
            }
            $(selector).remove();
        });

        $(selector).on("shown", function() {
            if (opts.onShown) {
                opts.onShown();
            }
        });

        $(selector).modal({
            remote: opts.url,
            keyboard: opts.keyboard,
            backdrop: opts.backdrop
        });

    };

    lib.hideModal = function() {
        $("#modal_element_id").modal('hide');
    };

})(imgvwr);
