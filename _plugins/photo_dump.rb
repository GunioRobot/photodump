module Jekyll
  
  class GeneratePhotoDump < Generator

    safe true
    priority :low

    def generate(site)
      Dir["_photos/*.jpg"].each do |file|
        photo = write_photo(file, site)
        site.posts << photo
      end
    end
    
    def write_photo(file, site)
      photo = Photo.new(site, site.source, File.dirname(file), File.basename(file))
      photo.render(site.layouts, site.site_payload)
      photo.write(site.dest)
      photo
    end
    
  end
  
  class Photo < Post

    MATCHER = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/

    # Photo name validator. Photo filenames must be like:
    #   2008-11-05-my-awesome-photo.jpg
    #
    # Returns <Bool>
    def self.valid?(name)
      name =~ MATCHER
    end

    # Initialize this Photo instance.
    #   +site+ is the Site
    #   +base+ is the String path to the dir containing the post file
    #   +name+ is the String filename of the post file
    #   +categories+ is an Array of Strings for the categories for this post
    #
    # Returns <Photo>
    def initialize(site, source, dir, name)
      @site = site
      @base = File.join(source, dir)
      @name = name
      self.data = {"layout" => "photo"}

      self.categories = [] # dir.split('/').reject { |x| x.empty? }
      self.tags       = []

      self.process(name)

      self.content = <<content
<img src="#{self.id}" />
content
    end

    # Extract information from the post filename
    #   +name+ is the String filename of the post file
    #
    # Returns nothing
    def process(name)
      m, cats, date, slug, ext = *name.match(MATCHER)
      self.date = Time.parse(date)
      self.slug = slug
      self.ext = ext
    end

    # The generated directory into which the photo will be placed
    # upon generation. This is just a photos directory for the _site dir
    # Returns <String>
    def dir
      "/photos"
    end

    # The full path and filename of the post.
    # Defined in the YAML of the post body
    # (Optional)
    #
    # Returns <String>
    def permalink
      self.data && self.data['permalink']
    end

    def template
      File.join(dir, "/:year-:month-:day-:title#{self.ext}")
    end

    # The UID for this post (useful in feeds)
    # e.g. /2008/11/05/my-awesome-post
    #
    # Returns <String>
    def id
      self.url
    end

    # Obtain destination path.
    #   +dest+ is the String path to the destination dir
    #
    # Returns destination file path.
    def destination(dest)
      File.join(dest, CGI.unescape(self.url))
    end

    # Write the generated post file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      path = destination(dest)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        src = File.join(@base, @name)
        f.write File.read( src )
      end
    end

    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      self.data.deep_merge({
        "title"      => self.data["title"] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url"        => self.url,
        "date"       => self.date,
        "id"         => self.id,
        "categories" => self.categories,
        "next"       => self.next,
        "previous"   => self.previous,
        "tags"       => self.tags,
        "content"    => self.content })
    end

    def inspect
      "<Photo: #{self.id}>"
    end
  end

end