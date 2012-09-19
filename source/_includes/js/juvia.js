(function() {
    var options = {
        container   : '#comments',
        site_key    : 'l4s7w2xqw8mv0ykiuo3oxumvfqkook6',
        topic_key   : '{{ page.url }}',
        topic_url   : '{{ site.url }}{{ page.url }}',
        topic_title : '{{ page.title }}' || '{{ site.url }}{{ page.url }}',
        include_base: true,
        include_css : false
    };

    function makeQueryString(options) {
        var key, params = [];
        for (key in options) {
            params.push(
                encodeURIComponent(key) +
                '=' +
                encodeURIComponent(options[key]));
        }
        return params.join('&');
    }

    function makeApiUrl(options) {
        // Makes sure that each call generates a unique URL, otherwise
        // the browser may not actually perform the request.
        if (!('_juviaRequestCounter' in window)) {
            window._juviaRequestCounter = 0;
        }

        var result =
            'http://juvia-vonavi.rhcloud.com/api/show_topic.js' +
            '?_c=' + window._juviaRequestCounter +
            '&' + makeQueryString(options);
        window._juviaRequestCounter++;
        return result;
    }

    var s       = document.createElement('script');
    s.async     = true;
    s.type      = 'text/javascript';
    s.className = 'juvia';
    s.src       = makeApiUrl(options);
    (document.getElementsByTagName('head')[0] ||
     document.getElementsByTagName('body')[0]).appendChild(s);
})();
