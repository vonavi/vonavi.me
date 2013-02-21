# A generator that creates a sitemap.xml page for jekyll sites, suitable for submission to
# google etc.
#
# To use it, simply drop this script into the _plugins directory of your Jekyll site.
#
# When you compile your jekyll site, this plugin will loop through the list of pages in your
# site, and generate an entry in sitemap.xml for each one.

require 'pathname'

module Jekyll

  # Monkey-patch an accessor for a page's containing folder, since
  # we need it to generate the sitemap.
  class Page
    def subfolder
      @dir
    end
  end

  # Sub-class Jekyll::StaticFile to allow recovery from unimportant exception
  # when writing the sitemap file.
  class StaticSitemapFile < StaticFile
    def write(dest)
      super(dest) rescue ArgumentError
      true
    end
  end

  # Generates a sitemap.xml file containing URLs of all pages and posts.
  class SitemapGenerator < Generator
    safe true
    priority :low

    # Generates the sitemap.xml file.
    #
    #  +site+ is the global Site object.
    def generate(site)
      # Create the destination folder if necessary.
      site_folder = site.config['destination']
      unless File.directory?(site_folder)
        p = Pathname.new(site_folder)
        p.mkdir
      end

      # Write the contents of sitemap.xml.
      File.open(File.join(site_folder, 'sitemap.xml'), 'w') do |f|
        f.write(generate_header())
        f.write(generate_content(site))
        f.write(generate_footer())
        f.close
      end

      # Add a static file entry for the zip file, otherwise Site::cleanup will remove it.
      site.static_files << Jekyll::StaticSitemapFile.new(site, site.dest, '/', 'sitemap.xml')
    end

    private

    # Returns the XML header.
    def generate_header
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
    end

    # Returns a string containing the the XML entries.
    #
    #  +site+ is the global Site object.
    def generate_content(site)
      result = ''

      # First, try to find any stand-alone pages.
      site.pages.each { |page|
        path = page.subfolder + '/' + page.name

        # Skip files that don't exist yet (e.g. paginator pages)
        if FileTest.exist?(site.source + path)
          mod_date = File.mtime(site.source + path)
          path = page.destination('')

          # Ignore hidden files
          next if path =~ /\/\./
          # Ignore SASS, SCSS, and CSS files
          next if path =~ /\.(sass|scss|css)$/
          # Ignore explicit files
          next if path =~ /\/(atom\.xml|robots\.txt)$/

          # Remove the trailing 'index.html' if there is one, and just output the folder name.
          path = path[0..-11] if path =~ /\/index\.html$/

          if page.data.has_key?('changefreq')
            changefreq = page.data["changefreq"]
          else
            changefreq = ''
          end

          result += entry(path, mod_date, changefreq, site)
        end
      }

      # Next, find all the posts.
      site.posts.each { |post|
        url = post.url
        url = url[0..-11] if url =~ /\/index\.html$/

        if post.data.has_key?('changefreq')
          changefreq = post.data['changefreq']
        else
          changefreq = ''
        end

        result += entry(url, post.date, changefreq, site)
      }

      result
    end

    # Returns the XML footer.
    def generate_footer
      "\n</urlset>"
    end

    # Creates an XML entry from the given path and date.
    #
    #  +path+ is the URL path to the page.
    #  +date+ is the date the file was modified (in the case of regular pages), or published (for blog posts).
    #  +changefreq+ is the frequency with which the page is expected to change (this information is used by
    #    e.g. the Googlebot). This may be specified in the page's YAML front matter. If it is not set, nothing
    #    is output for this property.
    def entry(path, date, changefreq, site)
      url = site.config['url']
      # Remove the trailing slash from the url if it is present, for consistency.
      url = url[0..-2] if url =~ /\/$/

      baseurl = site.config['baseurl']
      # Remove the trailing slash from the baseurl if it is present, for consistency.
      baseurl = baseurl[0..-2] if baseurl =~ /\/$/

      "
  <url>
    <loc>#{url}#{baseurl}#{path}</loc>
    <lastmod>#{date.strftime("%Y-%m-%d")}</lastmod>#{if changefreq.length > 0
          "\n    <changefreq>#{changefreq}</changefreq>" end}
  </url>"
    end
  end
end